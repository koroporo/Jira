const API_URL = '/tasks';
let taskModal;
let allTasks = [];
let taskTooltips = [];

/**
 * INITIALIZATION
 */
document.addEventListener('DOMContentLoaded', () => {
    taskModal = new bootstrap.Modal(document.getElementById('taskModal'));
    
    // Check if user is already logged in on page load
    checkAuth(); 
    
    // Search functionality
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', filterTasks);
    }
});

/**
 * AUTHENTICATION LOGIC
 */
async function handleLogin() {
    const id = document.getElementById('loginId').value;
    if (!id) return alert("Please enter a Profile ID!");

    try {
        const response = await fetch(`/users/login-id?profile_id=${id}`, { method: 'POST' });
        const result = await response.json();

        if (response.ok) {
            // Store user info in localStorage to persist session
            localStorage.setItem('currentUser', JSON.stringify(result.user));
            checkAuth();
        } else {
            alert("Error: " + (result.detail || "ID does not exist"));
        }
    } catch (err) {
        alert("Could not connect to the server!");
    }
}

function checkAuth() {
    const userJson = localStorage.getItem('currentUser');
    const loginSection = document.getElementById('loginSection');
    const mainContent = document.getElementById('mainContent');
    const nameDisplay = document.getElementById('userNameDisplay');

    if (userJson) {
        const user = JSON.parse(userJson);
        loginSection.style.display = 'none';
        mainContent.style.display = 'block';
        if (nameDisplay) nameDisplay.innerText = `Welcome, ${user.FullName}`;
        
        // Load data only after successful login
        loadTasks();
        loadMilestones();
    } else {
        loginSection.style.display = 'block';
        mainContent.style.display = 'none';
    }
}

function handleLogout() {
    localStorage.removeItem('currentUser');
    checkAuth();
}

/**
 * TASK MANAGEMENT (CRUD)
 */
async function loadTasks() {
    try {
        const response = await fetch(`${API_URL}/`);
        if (!response.ok) throw new Error("Failed to fetch tasks");
        
        allTasks = await response.json();
        renderTable(allTasks);
    } catch (err) {
        console.error("Load tasks error:", err);
    }
}

function filterTasks() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const filteredTasks = allTasks.filter(task => 
        (task.title || task.Title || "").toLowerCase().includes(searchTerm) ||
        (task.assignee_name || task.AssigneeName || "").toLowerCase().includes(searchTerm)
    );
    renderTable(filteredTasks);
}

function escapeHtml(text) {
    return String(text)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

function renderTable(tasks) {
    const tbody = document.getElementById('taskTableBody');

    // Dispose any existing Bootstrap tooltip instances to avoid orphaned tooltips
    taskTooltips.forEach(tooltip => tooltip.dispose());
    taskTooltips = [];

    tbody.innerHTML = tasks.map(t => {
        // Safe key check (Snake_case or CamelCase)
        const id = t.task_id || t.TaskID;
        const priority = t.task_priority || t.TaskPriority || 0;
        const dueDate = (t.due_date || t.DueDate) ? new Date(t.due_date || t.DueDate).toLocaleDateString('en-GB') : '---';
        const createdAt = (t.creation_time || t.CreationTime) ? new Date(t.creation_time || t.CreationTime).toLocaleDateString('en-GB') : '---';
        const reporterId = t.reporter_id || t.ReporterID || 'Unknown';
        const reporterName = t.reporter_name || t.ReporterName || '';
        const reporterLabel = reporterName ? `${reporterName} (#${reporterId})` : `#${reporterId}`;
        const tooltipText = escapeHtml(`Created: ${createdAt} | Reporter: ${reporterLabel}`);

        return `
            <tr data-bs-toggle="tooltip" data-bs-placement="top" title="${tooltipText}">
                <td>${id}</td>
                <td><strong>${t.title || t.Title}</strong></td>
                <td>${priority}</td>
                <td>${t.assignee_name || t.AssigneeName || 'Unassigned'}</td>
                <td><span class="badge bg-info">${t.status_name || t.StatusName || 'To Do'}</span></td>
                <td><small>${dueDate}</small></td>
                <td><small>${createdAt}</small></td>
                <td>
                    <button class="btn btn-sm btn-outline-warning" onclick="editTask(${id})">Edit</button>
                    <button class="btn btn-sm btn-outline-danger" onclick="deleteTask(${id})">Delete</button>
                </td>
            </tr>
        `;
    }).join('');

    // Initialize Bootstrap tooltips for the updated rows
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    taskTooltips = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
}

function toggleTypeDetail() {
    const type = document.getElementById('taskType').value;
    const container = document.getElementById('typeDetailContainer');
    const label = document.getElementById('typeDetailLabel');
    
    if (type === 'Task') {
        container.style.display = 'none';
    } else {
        container.style.display = 'block';
        if (type === 'Epic') label.innerText = 'Epic Goal';
        else if (type === 'Bug') label.innerText = 'Severity (1-5)';
        else label.innerText = 'Story Points';
    }
}

async function saveTask() {
    const id = document.getElementById('taskId').value;
    const user = JSON.parse(localStorage.getItem('currentUser'));

    const data = {
        title: document.getElementById('title').value,
        task_description: document.getElementById('description').value,
        task_priority: parseInt(document.getElementById('priority').value) || 0,
        status_id: parseInt(document.getElementById('statusId').value) || 1,
        
        // Polymorphism fields
        task_type: document.getElementById('taskType').value,
        type_detail: document.getElementById('typeDetail').value || "",

        // Foreign Keys
        project_id: 1, 
        reporter_id: user ? user.ProfileID : 1, 
        assignee_id: parseInt(document.getElementById('assigneeId').value) || null,
        milestone_id: parseInt(document.getElementById('milestoneId').value) || null,
        
        // Date field
        due_date: document.getElementById('dueDate').value || null,
        parent_task_id: null
    };

    console.log("Sending data to API:", data); // Check lại lần cuối trước khi gửi

    const method = id ? 'PUT' : 'POST';
    const url = id ? `${API_URL}/${id}` : `${API_URL}/`;

    try {
        const response = await fetch(url, {
            method: method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        if (response.ok) {
            taskModal.hide();
            loadTasks();
            loadMilestones();
        } else {
            const error = await response.json();
            alert("Error: " + (error.detail || "Validation failed"));
        }
    } catch (err) {
        console.error("Connection error:", err);
    }
}

async function deleteTask(id) {
    if (!confirm("Are you sure? This will check for active children before deleting.")) return;

    try {
        const response = await fetch(`${API_URL}/${id}?force=false`, { method: 'DELETE' });
        if (response.ok) {
            loadTasks();
            loadMilestones();
        } else {
            const result = await response.json();
            alert(result.detail); 
        }
    } catch (err) {
        alert("Network error while deleting task.");
    }
}

/**
 * MILESTONES (Function/Procedure Demonstration)
 */
async function loadMilestones() {
    try {
        const response = await fetch(`${API_URL}/reports/milestones`);
        if (!response.ok) throw new Error("Failed to fetch milestones");
        
        const data = await response.json();
        const container = document.getElementById('milestone-list');

        container.innerHTML = data.map(m => {
            const name = m.milestone_name || m.MilestoneName || 'Unnamed Milestone';
            const progress = m.progress !== undefined ? m.progress : (m.Progress || 0);
            const dueDate = m.end_date || m.EndDate;
            const formattedDate = dueDate ? new Date(dueDate).toLocaleDateString('en-GB') : 'No date';

            return `
                <div class="col-md-4 mb-3">
                    <div class="card shadow-sm border-0">
                        <div class="card-body">
                            <h6 class="fw-bold">${name}</h6>
                            <div class="progress" style="height: 18px;">
                                <div class="progress-bar bg-success" 
                                    role="progressbar" 
                                    style="width: ${progress}%" 
                                    aria-valuenow="${progress}" 
                                    aria-valuemin="0" 
                                    aria-valuemax="100">
                                    ${Math.round(progress)}%
                                </div>
                            </div>
                            <small class="text-muted mt-2 d-block">Due: ${formattedDate}</small>
                        </div>
                    </div>
                </div>
            `;
        }).join('');
    } catch (err) {
        console.error("Load milestones error:", err);
    }
}

function showCreateModal() {
    document.getElementById('taskForm').reset();
    document.getElementById('taskId').value = '';
    document.getElementById('modalTitle').innerText = 'Create Task';
    toggleTypeDetail(); // Ensure fields match default selection
    taskModal.show();
}

async function editTask(taskId) {
    try {
        const response = await fetch(`${API_URL}/${taskId}`);
        if (!response.ok) throw new Error("Task not found");
        
        const task = await response.json();
        
        // Map backend keys to form fields
        document.getElementById('taskId').value = task.task_id || task.TaskID;
        document.getElementById('title').value = task.title || task.Title;
        document.getElementById('description').value = task.task_description || task.TaskDescription || '';
        document.getElementById('priority').value = task.task_priority || task.TaskPriority || 0;
        
        document.getElementById('modalTitle').innerText = 'Edit Task';
        taskModal.show();
    } catch (err) {
        alert('Failed to load task details');
    }
}