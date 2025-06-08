-- Supabase database schema for ADHD Task Triage app
-- This script should be run in your Supabase SQL Editor

-- Create the tasks table
CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    priority TEXT NOT NULL CHECK (priority IN ('mustDo', 'couldDo')),
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    description TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- Create policy for users to only see their own tasks
CREATE POLICY "Users can view their own tasks" ON public.tasks
    FOR SELECT USING (auth.uid() = user_id);

-- Create policy for users to insert their own tasks
CREATE POLICY "Users can insert their own tasks" ON public.tasks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create policy for users to update their own tasks
CREATE POLICY "Users can update their own tasks" ON public.tasks
    FOR UPDATE USING (auth.uid() = user_id);

-- Create policy for users to delete their own tasks
CREATE POLICY "Users can delete their own tasks" ON public.tasks
    FOR DELETE USING (auth.uid() = user_id);

-- Create an index on user_id for better performance
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON public.tasks(user_id);

-- Create an index on created_at for better performance when ordering
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON public.tasks(created_at);
