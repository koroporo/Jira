const API_URL = '/tasks';
let taskModal;

document.addEventListener('DOMContentLoaded', () => {
    taskModal = new bootstrap.Modal(document.getElementById('taskModal'));
    loadTasks();
    loadMilestones();
    
    // Add search functionality
    document.getElementById('searchInput').addEventListener('input', filterTasks);
});

let allTasks = [];

async function loadTasks() {
    try {
        console.log('Loading tasks...');
        // In a real app, you'd call sp_get_task_list_detailed.
        // Here we fetch the collection from your FastAPI GET /tasks/ endpoint
        const response = await fetch(`${API_URL}/`);
        console.log('Response status:', response.status);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        allTasks = await response.json();
        console.log('Loaded tasks:', allTasks);
        renderTable(allTasks);
    } catch (err) {
        console.error("Failed to load tasks", err);
    }
}

function filterTasks() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const filteredTasks = allTasks.filter(task => 
        task.title.toLowerCase().includes(searchTerm) ||
        (task.assignee_name && task.assignee_name.toLowerCase().includes(searchTerm))
    );
    renderTable(filteredTasks);
}

function renderTable(tasks) {
    const tbody = document.getElementById('taskTableBody');
    tbody.innerHTML = tasks.map(t => `
        <tr class="priority-${t.task_priority}">
            <td>${t.task_id}</td>
            <td><strong>${t.title}</strong></td>
            <td>${t.task_priority}</td>
            <td>${t.assignee_name || 'Unassigned'}</td>
            <td><span class="badge bg-info">${t.status_name || 'To Do'}</span></td>
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
        assignee_id: 1 // Default assignee
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
        loadTasks(); // Refresh the task list
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
        loadTasks(); // Refresh the task list
    } else {
        alert(result.detail); // Displays your "Deletion not allowed" message from SQL
    }
}

// Requirement 3.3: Function Demonstration
async function loadMilestones() {
    try {
        console.log('Loading milestones...');
        const response = await fetch(`${API_URL}/reports/milestones`);
        console.log('Milestones response status:', response.status);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        const data = await response.json();
        console.log('Loaded milestones:', data);
        const container = document.getElementById('milestone-list');

        container.innerHTML = data.map(m => `
            <div class="col-md-4 mb-3">
                <div class="card">
                    <div class="card-body">
                        <h6>${m.milestone_name || 'Unnamed Milestone'}</h6>
                        <div class="progress">
                            <div class="progress-bar" style="width: ${m.progress}%">${m.progress}%</div>
                        </div>
                        <small class="text-muted">Due: ${m.end_date || 'No date'}</small>
                    </div>
                </div>
            </div>
        `).join('');
    } catch (err) {
        console.error("Failed to load milestones", err);
    }
}

function showCreateModal() {
    document.getElementById('taskForm').reset();
    document.getElementById('taskId').value = '';
    document.getElementById('modalTitle').innerText = 'Create Task';
    taskModal.show();
}

async function editTask(taskId) {
    // Fetch task details
    const response = await fetch(`${API_URL}/${taskId}`);
    if (!response.ok) {
        alert('Failed to load task details');
        return;
    }
    const task = await response.json();
    
    // Populate the form
    document.getElementById('taskId').value = task.task_id;
    document.getElementById('title').value = task.title;
    document.getElementById('description').value = task.task_description || '';
    document.getElementById('priority').value = task.task_priority;
    // Note: status_id might need to be handled differently if not in the response
    
    document.getElementById('modalTitle').innerText = 'Edit Task';
    taskModal.show();
}