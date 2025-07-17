from flask import Blueprint, render_template, request, redirect, url_for, flash, jsonify
from app import db
from app.models import Note

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
    notes = Note.query.order_by(Note.timestamp.desc()).all()
    return render_template('index.html', notes=notes)

@bp.route('/api/notes', methods=['GET'])
def api_notes():
    """API endpoint to get all notes as JSON"""
    notes = Note.query.order_by(Note.timestamp.desc()).all()
    return jsonify([note.to_dict() for note in notes])

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