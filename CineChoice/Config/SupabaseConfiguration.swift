//
//  SupabaseConfiguration.swift
//  CineChoice
//
//  Created by Lucky on 01/05/24.
//

import Foundation
import Supabase

struct SupabaseConfiguration {
    static let supabase = SupabaseClient(supabaseURL: URL(string: "https://shucboqluxegybsrzyfz.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNodWNib3FsdXhlZ3lic3J6eWZ6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcxNDM4MjEwOCwiZXhwIjoyMDI5OTU4MTA4fQ.PE-zDVm6PhmWvhmXdNa0PGCy9V-I7p9Dv70aJCIuqQM")
}
