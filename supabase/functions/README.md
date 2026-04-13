# Supabase Edge Functions for SmartCampus

Edge Functions allow you to run server-side logic in globally distributed Deno environments. This is ideal for high-concurrency reporting tasks that would otherwise slow down the Flutter app.

## 1. Prerequisites

Ensure you have the Supabase CLI installed:
```bash
npx supabase init
npx supabase login
```

## 2. Create your first function

```bash
npx supabase functions new generate_report
```

---

## 3. Sample Function Template (`generate_report/index.ts`)

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { classId, startDate, endDate } = await req.json()
  
  // 1. Initialize Supabase Admin Client
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  // 2. Perform heavy calculations (e.g., aggregate attendance across 1000s of records)
  const { data, error } = await supabase
    .rpc('calculate_class_attendance_stats', { 
      p_class_id: classId, 
      p_start_date: startDate, 
      p_end_date: endDate 
    })

  return new Response(
    JSON.stringify(data),
    { headers: { "Content-Type": "application/json" } }
  )
})
```

---

## 4. Deploying to Production

```bash
npx supabase functions deploy generate_report
```

## 5. Calling from Flutter

```dart
final response = await supabase.functions.invoke('generate_report', body: {
  'classId': 'YOUR_CLASS_ID',
  'startDate': '2026-03-01',
  'endDate': '2026-03-31',
});
```
