from django.shortcuts import render, redirect, get_object_or_404
from django.http import JsonResponse
from .models import Todo


def index(request):
    """TODOリストを表示"""
    todos = Todo.objects.all()
    return render(request, 'todo/index.html', {'todos': todos})


def create(request):
    """新しいTODOを作成"""
    if request.method == 'POST':
        title = request.POST.get('title')
        description = request.POST.get('description', '')
        if title:
            Todo.objects.create(title=title, description=description)
        return redirect('todo:index')
    return redirect('todo:index')


def toggle(request, todo_id):
    """TODOの完了状態を切り替え"""
    todo = get_object_or_404(Todo, id=todo_id)
    todo.completed = not todo.completed
    todo.save()
    return redirect('todo:index')


def delete(request, todo_id):
    """TODOを削除"""
    todo = get_object_or_404(Todo, id=todo_id)
    todo.delete()
    return redirect('todo:index')


def api_list(request):
    """API: TODOリストを取得"""
    todos = Todo.objects.all().values('id', 'title', 'description', 'completed', 'created_at', 'updated_at')
    return JsonResponse(list(todos), safe=False)
