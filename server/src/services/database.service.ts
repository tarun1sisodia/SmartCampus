import supabase from '../utils/supabase';
import logger from '../utils/logger';
import { PostgrestError } from '@supabase/supabase-js';

export class DatabaseService {
  protected tableName: string;

  constructor(tableName: string) {
    this.tableName = tableName;
  }

  protected async handleError(error: PostgrestError | null, operation: string): Promise<void> {
    if (error) {
      logger.error(`Database ${operation} error:`, { error, table: this.tableName });
      throw new Error(`${operation} operation failed: ${error.message}`);
    }
  }

  async findOne(id: string) {
    const { data, error } = await supabase
      .from(this.tableName)
      .select('*')
      .eq('id', id)
      .single();
    
    await this.handleError(error, 'findOne');
    return data;
  }

  async findMany(query: object = {}) {
    const { data, error } = await supabase
      .from(this.tableName)
      .select('*')
      .match(query);
    
    await this.handleError(error, 'findMany');
    return data;
  }

  async create(data: object) {
    const { data: created, error } = await supabase
      .from(this.tableName)
      .insert(data)
      .select()
      .single();
    
    await this.handleError(error, 'create');
    return created;
  }

  async update(id: string, data: object) {
    const { data: updated, error } = await supabase
      .from(this.tableName)
      .update(data)
      .eq('id', id)
      .select()
      .single();
    
    await this.handleError(error, 'update');
    return updated;
  }

  async delete(id: string) {
    const { error } = await supabase
      .from(this.tableName)
      .delete()
      .eq('id', id);
    
    await this.handleError(error, 'delete');
    return true;
  }
}

export default DatabaseService;
