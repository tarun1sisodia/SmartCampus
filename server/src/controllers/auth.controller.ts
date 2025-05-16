import { Request, Response } from 'express';
import supabase from '../utils/supabase';

export class AuthController {
  static async signup(req: Request, res: Response) {
    try {
      const { email, password, role = 'user' } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          status: 'error',
          message: 'Email and password are required'
        });
      }

      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            role
          }
        }
      });

      if (error) {
        return res.status(400).json({
          status: 'error',
          message: error.message
        });
      }

      return res.status(201).json({
        status: 'success',
        message: 'User created successfully',
        data: {
          user: data.user,
          session: data.session
        }
      });
    } catch (error) {
      console.error('Signup error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Internal server error during signup'
      });
    }
  }

  static async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          status: 'error',
          message: 'Email and password are required'
        });
      }

      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      });

      if (error) {
        return res.status(401).json({
          status: 'error',
          message: error.message
        });
      }

      return res.status(200).json({
        status: 'success',
        data: {
          user: data.user,
          session: data.session
        }
      });
    } catch (error) {
      console.error('Login error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Internal server error during login'
      });
    }
  }

  static async logout(req: Request, res: Response) {
    try {
      const { error } = await supabase.auth.signOut();

      if (error) {
        return res.status(400).json({
          status: 'error',
          message: error.message
        });
      }

      return res.status(200).json({
        status: 'success',
        message: 'Successfully logged out'
      });
    } catch (error) {
      console.error('Logout error:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Internal server error during logout'
      });
    }
  }
}

export default AuthController;
