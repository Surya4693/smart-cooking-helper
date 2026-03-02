#!/usr/bin/env python3
"""
Smart Cooking Helper - Quick Setup and Testing Script
Provides one-command setup and verification
"""

import os
import subprocess
import sys
import platform

class SmartCookingSetup:
    def __init__(self):
        self.project_root = os.path.dirname(os.path.abspath(__file__))
        self.is_windows = platform.system() == "Windows"
        
    def run_command(self, cmd, cwd=None):
        """Run a command and return success status"""
        try:
            result = subprocess.run(
                cmd,
                cwd=cwd,
                shell=True,
                capture_output=True,
                text=True
            )
            return result.returncode == 0, result.stdout, result.stderr
        except Exception as e:
            return False, "", str(e)
    
    def setup_backend(self):
        """Setup backend environment"""
        print("\n📦 Setting up Backend...")
        backend_path = os.path.join(self.project_root, "backend")
        
        # Create virtual environment
        venv_path = os.path.join(backend_path, "venv")
        if not os.path.exists(venv_path):
            cmd = f"python -m venv venv"
            success, _, err = self.run_command(cmd, cwd=backend_path)
            if success:
                print("✅ Virtual environment created")
            else:
                print(f"❌ Failed to create venv: {err}")
                return False
        
        # Activate venv and install dependencies
        if self.is_windows:
            activate_cmd = "venv\\Scripts\\activate.bat && pip install -r requirements.txt"
        else:
            activate_cmd = "source venv/bin/activate && pip install -r requirements.txt"
        
        success, _, err = self.run_command(activate_cmd, cwd=backend_path)
        if success:
            print("✅ Dependencies installed")
        else:
            print(f"❌ Failed to install dependencies: {err}")
            return False
        
        return True
    
    def setup_frontend(self):
        """Setup frontend environment"""
        print("\n📱 Setting up Frontend...")
        frontend_path = os.path.join(self.project_root, "frontend")
        
        # Check Flutter installation
        success, _, _ = self.run_command("flutter --version")
        if not success:
            print("❌ Flutter not found. Please install Flutter first.")
            return False
        
        # Get Flutter dependencies
        success, _, err = self.run_command("flutter pub get", cwd=frontend_path)
        if success:
            print("✅ Flutter dependencies installed")
        else:
            print(f"❌ Failed to install Flutter deps: {err}")
            return False
        
        return True
    
    def setup_database(self):
        """Setup database"""
        print("\n🗄️  Setting up Database...")
        
        # Check PostgreSQL installation
        success, _, _ = self.run_command("psql --version")
        if not success:
            print("⚠️  PostgreSQL not found. Please install PostgreSQL manually.")
            print("Visit: https://www.postgresql.org/download/")
            return True  # Don't fail, user can do this manually
        
        # Create database
        db_path = os.path.join(self.project_root, "database")
        sql_file = os.path.join(db_path, "schema.sql")
        
        cmd = f'psql -U postgres -d smart_cooking_helper -f "{sql_file}"'
        success, _, err = self.run_command(cmd)
        if success:
            print("✅ Database schema created")
        else:
            print(f"⚠️  Database setup - manual setup may be needed: {err}")
        
        return True
    
    def verify_setup(self):
        """Verify the setup"""
        print("\n🔍 Verifying Setup...")
        
        # Check backend
        backend_path = os.path.join(self.project_root, "backend")
        main_py = os.path.join(backend_path, "main.py")
        if os.path.exists(main_py):
            print("✅ Backend files present")
        else:
            print("❌ Backend files missing")
        
        # Check frontend
        frontend_path = os.path.join(self.project_root, "frontend")
        pubspec = os.path.join(frontend_path, "pubspec.yaml")
        if os.path.exists(pubspec):
            print("✅ Frontend files present")
        else:
            print("❌ Frontend files missing")
        
        # Check database
        db_path = os.path.join(self.project_root, "database")
        schema = os.path.join(db_path, "schema.sql")
        if os.path.exists(schema):
            print("✅ Database schema present")
        else:
            print("❌ Database schema missing")
        
        print("\n✅ Verification complete!")
        return True
    
    def print_next_steps(self):
        """Print next steps"""
        print("\n" + "="*60)
        print("📋 NEXT STEPS")
        print("="*60)
        print("\n1. Configure Firebase:")
        print("   - Create Firebase project at https://console.firebase.google.com")
        print("   - Download credentials")
        print("   - Update frontend/firebase_options.dart")
        
        print("\n2. Configure Backend (.env):")
        print("   - Update DATABASE_URL")
        print("   - Add Firebase credentials")
        print("   - Add API keys (Spoonacular, Open Food Facts, etc.)")
        
        print("\n3. Start Backend:")
        print("   cd backend")
        if self.is_windows:
            print("   venv\\Scripts\\activate")
        else:
            print("   source venv/bin/activate")
        print("   python main.py")
        
        print("\n4. Start Frontend:")
        print("   cd frontend")
        print("   flutter run")
        
        print("\n5. Test API:")
        print("   Open http://localhost:8000/docs in your browser")
        
        print("\n6. Deploy:")
        print("   Follow DEPLOYMENT.md for cloud deployment options")
        
        print("\n" + "="*60)
        print("For more info: see README.md, DEPLOYMENT.md, TESTING.md")
        print("="*60)

def main():
    setup = SmartCookingSetup()
    
    print("\n" + "="*60)
    print("🍳 Smart Cooking Helper - Setup Script")
    print("="*60)
    
    # Run setup
    try:
        if not setup.setup_backend():
            print("⚠️  Backend setup incomplete")
        
        if not setup.setup_frontend():
            print("⚠️  Frontend setup incomplete")
        
        if not setup.setup_database():
            print("⚠️  Database setup incomplete")
        
        setup.verify_setup()
        setup.print_next_steps()
        
    except KeyboardInterrupt:
        print("\n\n❌ Setup interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
