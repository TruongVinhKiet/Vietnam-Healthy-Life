-- Fix table names to lowercase for PostgreSQL compatibility

-- Create UserHealthCondition table (lowercase)
CREATE TABLE IF NOT EXISTS userhealthcondition (
    user_condition_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    condition_id INT NOT NULL REFERENCES healthcondition(condition_id) ON DELETE CASCADE,
    diagnosis_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    severity VARCHAR(20),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, condition_id)
);

-- Create UserMedication table (lowercase)
CREATE TABLE IF NOT EXISTS usermedication (
    user_medication_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    medication_name VARCHAR(200) NOT NULL,
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create DailyMedication table (lowercase)
CREATE TABLE IF NOT EXISTS dailymedication (
    daily_med_id SERIAL PRIMARY KEY,
    user_medication_id INT NOT NULL REFERENCES usermedication(user_medication_id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    time_scheduled TIME,
    time_taken TIME,
    status VARCHAR(20) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_medication_id, date, time_scheduled)
);

-- Create MedicationSchedule table (lowercase)  
CREATE TABLE IF NOT EXISTS medicationschedule (
    schedule_id SERIAL PRIMARY KEY,
    user_medication_id INT NOT NULL REFERENCES usermedication(user_medication_id) ON DELETE CASCADE,
    time_of_day TIME NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_medication_id, time_of_day)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_userhealthcondition_user ON userhealthcondition(user_id);
CREATE INDEX IF NOT EXISTS idx_userhealthcondition_status ON userhealthcondition(status);
CREATE INDEX IF NOT EXISTS idx_usermedication_user ON usermedication(user_id);
CREATE INDEX IF NOT EXISTS idx_usermedication_status ON usermedication(status);
CREATE INDEX IF NOT EXISTS idx_dailymedication_date ON dailymedication(date);
CREATE INDEX IF NOT EXISTS idx_dailymedication_status ON dailymedication(status);
