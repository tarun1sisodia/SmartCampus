import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Global cache (Deno isolates are reused across requests)
const cache = new Map();
const CACHE_TTL = 300000; // 5 minutes in ms

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { classId, startDate, endDate } = await req.json()

    if (!classId) {
      throw new Error('classId is required')
    }

    // 0. Check Cache
    const cacheKey = `${classId}:${startDate || ''}:${endDate || ''}`;
    const cachedEntry = cache.get(cacheKey);
    if (cachedEntry && (Date.now() - cachedEntry.timestamp < CACHE_TTL)) {
       console.log(`Cache hit for ${cacheKey}`);
       return new Response(JSON.stringify(cachedEntry.data), {
         headers: { 
           ...corsHeaders, 
           'Content-Type': 'application/json',
           'X-Cache': 'HIT',
           'Cache-Control': 'public, max-age=300'
         },
       });
    }

    // Initialize Supabase Client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    console.log(`Calculating stats for class ${classId} from ${startDate} to ${endDate}`)

    // 1. Fetch all attendance sessions for the class in range
    let query = supabase
      .from('attendance_sessions')
      .select('id, date')
      .eq('class_id', classId)

    if (startDate) query = query.gte('date', startDate)
    if (endDate) query = query.lte('date', endDate)

    const { data: sessions, error: sessionsError } = await query
    
    if (sessionsError) throw sessionsError
    if (!sessions || sessions.length === 0) {
      return new Response(JSON.stringify({ totalSessions: 0, students: {} }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const sessionIds = sessions.map(s => s.id)

    // 2. Fetch all attendance records for those sessions
    const { data: records, error: recordsError } = await supabase
      .from('attendance_records')
      .select('student_id, status')
      .in('session_id', sessionIds)

    if (recordsError) throw recordsError

    // 3. Aggregate statistics
    const stats = {}
    const totalSessions = sessions.length

    records.forEach(record => {
      const sId = record.student_id
      if (!stats[sId]) {
        stats[sId] = { present: 0, absent: 0, late: 0, excused: 0, total: 0 }
      }
      
      stats[sId][record.status]++
      stats[sId].total++
    })

    // Calculate percentages
    Object.keys(stats).forEach(sId => {
      const s = stats[sId]
      // Standard formula: (Present + 0.5 * Late) / Total
      s.attendancePercentage = totalSessions > 0 
        ? ((s.present + (s.late * 0.5)) / totalSessions) * 100 
        : 0
    })

    const result = { 
      totalSessions,
      studentCount: Object.keys(stats).length,
      stats 
    };

    // 4. Save to Cache
    cache.set(cacheKey, {
      timestamp: Date.now(),
      data: result
    });

    return new Response(
      JSON.stringify(result),
      { 
        headers: { 
          ...corsHeaders, 
          'Content-Type': 'application/json',
          'X-Cache': 'MISS',
          'Cache-Control': 'public, max-age=300'
        } 
      }
    )

  } catch (error) {
    console.error('Error calculating statistics:', error.message)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
