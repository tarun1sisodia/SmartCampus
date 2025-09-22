# Backend Setup Guide

This guide provides step-by-step instructions for setting up the Supabase backend for the SmartCampus attendance application.

## Prerequisites

- A free Supabase account. You can create one at [supabase.com](https://supabase.com).
- Git installed on your local machine.

## Step 1: Create a New Supabase Project

1.  Go to the [Supabase dashboard](https://app.supabase.io).
2.  Click on **New Project**.
3.  Choose an organization and give your project a **Name**.
4.  Generate a secure **Database Password** and save it in a safe place.
5.  Select a **Region** that is closest to your users.
6.  Click **Create New Project**.

## Step 2: Set Up the Database Schema

Once your project is created, you need to set up the database schema using the provided SQL script.

1.  In the Supabase dashboard, navigate to the **SQL Editor** from the left sidebar.
2.  Click on **New query**.
3.  Open the `complete_setup_database.sql` file located in this `backend` directory.
4.  Copy the entire content of the SQL file.
5.  Paste the content into the Supabase SQL Editor.
6.  Click the **RUN** button to execute the script.

This will create all the necessary tables, views, functions, and row-level security policies for the application to work correctly.

## Step 3: Obtain API Credentials

The Flutter application needs to connect to your Supabase project. For this, you need the project's API URL and `anon` key.

1.  In the Supabase dashboard, go to **Project Settings** (the gear icon in the left sidebar).
2.  Click on the **API** tab.
3.  Under **Project API keys**, you will find the **Project URL** and the **`anon` `public`** key.
4.  You will need these values for the next step.

## Step 4: Configure the Frontend Application

To securely manage your API credentials, the frontend application uses a `.env` file.

1.  In the root directory of the project, create a file named `.env`.
2.  Add the following lines to the `.env` file, replacing the placeholder values with the credentials you obtained in the previous step:

    ```
    SUPABASE_URL=YOUR_SUPABASE_URL
    SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
    ```

3.  **Important**: The `.env` file contains sensitive information and should **never** be committed to version control. The project's `.gitignore` file is already configured to ignore this file.

4.  An example file, `.env.example`, is provided in the root directory to show the required environment variables.

After completing these steps, your backend will be fully configured, and the Flutter application will be able to connect to it.
