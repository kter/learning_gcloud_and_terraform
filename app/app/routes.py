"""
Application routes for the TODO application
"""

from flask import Blueprint, jsonify, redirect, render_template, request, url_for
from models import Todo, db

bp = Blueprint("main", __name__)


@bp.route("/")
def index():
    """Display TODO list"""
    todos = Todo.query.order_by(Todo.created_at.desc()).all()
    return render_template("index.html", todos=todos)


@bp.route("/create", methods=["POST"])
def create():
    """Create a new TODO item"""
    title = request.form.get("title")
    description = request.form.get("description", "")

    if title:
        todo = Todo(title=title, description=description)
        db.session.add(todo)
        db.session.commit()

    return redirect(url_for("main.index"))


@bp.route("/toggle/<int:todo_id>", methods=["POST"])
def toggle(todo_id):
    """Toggle TODO completion status"""
    todo = Todo.query.get_or_404(todo_id)
    todo.completed = not todo.completed
    db.session.commit()

    return redirect(url_for("main.index"))


@bp.route("/delete/<int:todo_id>", methods=["POST"])
def delete(todo_id):
    """Delete a TODO item"""
    todo = Todo.query.get_or_404(todo_id)
    db.session.delete(todo)
    db.session.commit()

    return redirect(url_for("main.index"))


@bp.route("/api/list")
def api_list():
    """API: Get all TODO items as JSON"""
    todos = Todo.query.order_by(Todo.created_at.desc()).all()
    return jsonify([todo.to_dict() for todo in todos])
