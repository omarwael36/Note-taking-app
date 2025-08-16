from flask import Blueprint, render_template, request, redirect, url_for, flash, jsonify
from app import db
from app.models import Note
from sqlalchemy import text

bp = Blueprint('main', __name__)

@bp.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        content = request.form.get('content')
        if content and content.strip():
            note = Note(content=content.strip())
            db.session.add(note)
            db.session.commit()
            flash('Note saved successfully!', 'success')
        else:
            flash('Please enter a note before saving.', 'error')
        return redirect(url_for('main.index'))
    
    # Get all notes ordered by newest first
    notes = Note.query.order_by(Note.created_at.desc()).all()
    return render_template('index.html', notes=notes)

@bp.route('/notes', methods=['GET'])
@bp.route('/api/notes', methods=['GET'])
def api_notes():
    """API endpoint to get all notes as JSON"""
    notes = Note.query.order_by(Note.created_at.desc()).all()
    return jsonify([note.to_dict() for note in notes])

@bp.route('/notes', methods=['POST'])
@bp.route('/api/notes', methods=['POST'])
def api_create_note():
    """API endpoint to create a new note"""
    data = request.get_json()
    content = data.get('content') if data else None
    
    if not content or not content.strip():
        return jsonify({'error': 'Content is required'}), 400
    
    note = Note(content=content.strip())
    db.session.add(note)
    db.session.commit()
    
    return jsonify(note.to_dict()), 201

@bp.route('/healthz', methods=['GET'])
def health_check():
    """Health endpoint that checks database connectivity"""
    try:
        # Test database connection
        db.session.execute(text('SELECT 1'))
        
        # Check if notes table exists
        db.session.execute(text('SELECT COUNT(*) FROM notes'))
        
        return jsonify({
            'status': 'healthy',
            'database': 'connected',
            'timestamp': Note.query.first().created_at.isoformat() + 'Z' if Note.query.first() else None
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'database': 'disconnected',
            'error': str(e)
        }), 503 