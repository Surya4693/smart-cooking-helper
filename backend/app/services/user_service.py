from sqlalchemy.orm import Session
from app.database.models import UserProfile
from uuid import uuid4
from datetime import datetime
from typing import Optional, Dict, Any

class UserService:
    
    def create_user(
        self,
        db: Session,
        email: str,
        display_name: Optional[str] = None,
        dietary_preferences: Optional[list] = None,
    ) -> Dict[str, Any]:
        """Create a new user profile"""
        try:
            user = UserProfile(
                id=str(uuid4()),
                email=email,
                display_name=display_name or email.split('@')[0],
                dietary_preferences=dietary_preferences or [],
            )

            db.add(user)
            db.commit()
            db.refresh(user)
            return self.format_user(user)
        except Exception as e:
            db.rollback()
            raise Exception(f"Create user error: {str(e)}")

    def get_user_by_id(
        self,
        db: Session,
        user_id: str,
    ) -> Optional[Dict[str, Any]]:
        """Get user profile by ID"""
        try:
            user = db.query(UserProfile).filter(
                UserProfile.id == user_id
            ).first()

            if not user:
                return None

            return self.format_user(user)
        except Exception as e:
            raise Exception(f"Get user error: {str(e)}")

    def get_user_by_email(
        self,
        db: Session,
        email: str,
    ) -> Optional[Dict[str, Any]]:
        """Get user profile by email"""
        try:
            user = db.query(UserProfile).filter(
                UserProfile.email == email
            ).first()

            if not user:
                return None

            return self.format_user(user)
        except Exception as e:
            raise Exception(f"Get user by email error: {str(e)}")

    def update_user(
        self,
        db: Session,
        user_id: str,
        display_name: Optional[str] = None,
        photo_url: Optional[str] = None,
        dietary_preferences: Optional[list] = None,
    ) -> Optional[Dict[str, Any]]:
        """Update user profile"""
        try:
            user = db.query(UserProfile).filter(
                UserProfile.id == user_id
            ).first()

            if not user:
                return None

            if display_name:
                user.display_name = display_name
            if photo_url:
                user.photo_url = photo_url
            if dietary_preferences is not None:
                user.dietary_preferences = dietary_preferences

            user.updated_at = datetime.utcnow()

            db.commit()
            db.refresh(user)
            return self.format_user(user)
        except Exception as e:
            db.rollback()
            raise Exception(f"Update user error: {str(e)}")

    def update_dietary_preferences(
        self,
        db: Session,
        user_id: str,
        preferences: list,
    ) -> Optional[Dict[str, Any]]:
        """Update user's dietary preferences"""
        try:
            user = db.query(UserProfile).filter(
                UserProfile.id == user_id
            ).first()

            if not user:
                return None

            user.dietary_preferences = preferences
            user.updated_at = datetime.utcnow()

            db.commit()
            db.refresh(user)
            return self.format_user(user)
        except Exception as e:
            db.rollback()
            raise Exception(f"Update preferences error: {str(e)}")

    def format_user(self, user: UserProfile) -> Dict[str, Any]:
        """Format user object to dictionary"""
        return {
            "id": user.id,
            "email": user.email,
            "display_name": user.display_name,
            "photo_url": user.photo_url,
            "dietary_preferences": user.dietary_preferences,
            "created_at": user.created_at.isoformat(),
            "updated_at": user.updated_at.isoformat(),
        }
