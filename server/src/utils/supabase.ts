import { createClient } from '@supabase/supabase-js';
import config from '../config/config';
import logger from './logger';

const initializeSupabase = () => {
  try {
    if (!config.supabase.url || !config.supabase.serviceRoleKey) {
      logger.warn('Supabase configuration missing. Please update .env file with your Supabase credentials.');
      return null;
    }

    return createClient(
      config.supabase.url,
      config.supabase.serviceRoleKey,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    );
  } catch (error) {
    logger.error('Failed to initialize Supabase client:', error);
    return null;
  }
};

const supabase = initializeSupabase();

export default supabase;
