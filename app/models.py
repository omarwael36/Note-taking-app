from datetime import datetime
from app import db

class Note(db.Model):
    __tablename__ = 'notes'
    
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, index=True, default=datetime.utcnow)
    
    # Keep timestamp as alias for backward compatibility
    @property
    def timestamp(self):
        return self.created_at
    
    def __repr__(self):
        return f'<Note {self.id}: {self.content[:50]}...>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'content': self.content,
            'created_at': self.created_at.isoformat() + 'Z'
        } 