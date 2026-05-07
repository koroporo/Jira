const API_URL = '/tasks';
let taskModal;

document.addEventListener('DOMContentLoaded', () => {
    taskModal = new bootstrap.Modal(document.getElementById('taskModal'));
    loadTasks();
    loadMilestones();
});

// Requirement 3.2: Load Data using Stored Procedure
async function loadTasks() {
    try {
        // In a real app, you'd call sp_get_task_list_detailed.
        // Here we fetch the collection from your FastAPI GET /tasks/ endpoint
        const response = await fetch(`${API_URL}/`);
        const tasks = await response.json();
        renderTable(tasks);
    } catch (err) {
        console.error("Failed to load tasks", err);
    }
}

function renderTable(tasks) {
    const tbody = document.getElementById('taskTableBody');
    tbody.innerHTML = tasks.map(t => `
        <tr class="priority-${t.task_priority}">
            <td>${t.task_id}</td>
            <td><strong>${t.title}</strong></td>
            <td>${t.task_priority}</td>
            <td>${t.assignee_id || 'Unassigned'}</td>
            <td><span class="badge bg-info">${t.status_id || 'To Do'}</span></td>
            <td>
                <button class="btn btn-sm btn-outline-warning" onclick="editTask(${t.task_id})">Edit</button>
                <button class="btn btn-sm btn-outline-danger" onclick="deleteTask(${t.task_id})">Delete</button>
            </td>
        </tr>
    `).join('');
}

// Requirement 3.1: Insert/Update Operations
async function saveTask() {
    const id = document.getElementById('taskId').value;
    const data = {
        title: document.getElementById('title').value,
        task_description: document.getElementById('description').value,
        task_priority: parseInt(document.getElementById('priority').value),
        status_id: parseInt(document.getElementById('statusId').value),
        project_id: 1, // Default for demo
        reporter_id: 1,
        parent_task_id: 0
    };

    const method = id ? 'PUT' : 'POST';
    const url = id ? `${API_URL}/${id}` : `${API_URL}/`;

    const response = await fetch(url, {
        method: method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });

    const result = await response.json();
    if (response.ok) {
        taskModal.hide();
        loadTasks();
    } else {
        // Requirement 3.2: Meaningful Error Messages
        alert(`Error: ${result.detail || 'Check database constraints (Hierarchy/Status)'}`);
    }
}

// Requirement 3.1: Delete Operation
async function deleteTask(id) {
    if (!confirm("Are you sure? This calls sp_delete_task which checks for active children.")) return;

    const response = await fetch(`${API_URL}/${id}?force=false`, { method: 'DELETE' });
    const result = await response.json();

    if (response.ok) {
        loadTasks();
    } else {
        alert(result.detail); // Displays your "Deletion not allowed" message from SQL
    }
}

// Requirement 3.3: Function Demonstration
async function loadMilestones() {
    const response = await fetch(`${API_URL}/reports/milestones`);
    const data = await response.json();
    const container = document.getElementById('milestone-list');

    container.innerHTML = data.map(m => `
        <div class="col-md-4 mb-3">
            <div class="card">
                <div class="card-body">
                    <h6>${m.MilestoneName}</h6>
                    <div class="progress">
                        <div class="progress-bar" style="width: ${m.Progress}%">${m.Progress}%</div>
                    </div>
                </div>
            </div>
        </div>
    `).join('');
}

function showCreateModal() {
    document.getElementById('taskForm').reset();
    document.getElementById('taskId').value = '';
    document.getElementById('modalTitle').innerText = 'Create Task';
    taskModal.show();
}