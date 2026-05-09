const API_URL = '/tasks';
let taskModal;
let allTasks = [];

function pick(obj, keys, fallback = '') {
    for (const key of keys) {
        if (obj && obj[key] !== undefined && obj[key] !== null) {
            return obj[key];
        }
    }
    return fallback;
}

function formatDate(value) {
    if (!value) return '---';
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return '---';
    return date.toLocaleDateString('en-GB');
}

/**
 * INITIALIZATION
 */
document.addEventListener('DOMContentLoaded', () => {
    taskModal = new bootstrap.Modal(document.getElementById('taskModal'));
    
    // Check if user is already logged in on page load
    checkAuth(); 
    const searchInput = document.getElementById('searchInput');

    if (searchInput) {
        searchInput.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
                applyFilters();
            }
        });
    }


    const projectFilterInput = document.getElementById('projectFilter');
    if (projectFilterInput) {
        projectFilterInput.addEventListener('input', applyFilters);
        projectFilterInput.addEventListener('change', applyFilters);
        projectFilterInput.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
                applyFilters();
            }
        });
    }

    const statusFilterInput = document.getElementById('statusFilter');

    if (statusFilterInput) {
        statusFilterInput.addEventListener('change', applyFilters);
    }

    const performanceProjectInput = document.getElementById('performanceProjectId');
    if (performanceProjectInput) {
        performanceProjectInput.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
                loadPerformanceReport();
            }
        });
    }

    const performanceMinInput = document.getElementById('performanceMinTasks');
    if (performanceMinInput) {
        performanceMinInput.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
                loadPerformanceReport();
            }
        });
    }

    const staffProfileInput = document.getElementById('staffProfileId');
    if (staffProfileInput) {
        staffProfileInput.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
                loadStaffReport();
            }
        });
    }

    const performanceBody = document.getElementById('performanceTableBody');
    if (performanceBody) {
        performanceBody.innerHTML = `
            <tr>
                <td colspan="5" class="text-center text-muted py-3">Enter a valid Project ID, then click Load Performance Report.</td>
            </tr>
        `;
    }

    const staffContainer = document.getElementById('staffReportContainer');
    if (staffContainer) {
        staffContainer.innerHTML = '<div class="col-12 text-muted">Enter a profile ID, then click Load Staff Report.</div>';
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

        const staffProfileInput = document.getElementById('staffProfileId');
        if (staffProfileInput && user.ProfileID) {
            staffProfileInput.value = user.ProfileID;
        }
        
        // Load data only after successful login
        loadTasks();
        loadMilestones();
        loadStaffReport(user.ProfileID);
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
    const projectFilterVal = document.getElementById('projectFilter')?.value;
    const statusFilterVal = document.getElementById('statusFilter')?.value;
    const keywordVal = document.getElementById('searchInput')?.value?.trim();

    const params = new URLSearchParams();

    if (projectFilterVal) {
        params.append('project_id', projectFilterVal);
    }

    if (statusFilterVal) {
        params.append('status_id', statusFilterVal);
    }

    if (keywordVal) {
        params.append('keyword', keywordVal);
    }

    const query = params.toString()
        ? `?${params.toString()}`
        : '';

    try {
        const response = await fetch(`${API_URL}/${query}`);

        if (!response.ok) {
            throw new Error("Failed to fetch tasks");
        }

        allTasks = await response.json();

        renderTable(allTasks);

    } catch (err) {
        console.error("Load tasks error:", err);
    }
}

function filterTasks() {
    loadTasks();
}

function renderTable(tasks) {
    console.log(tasks[0])
    const tbody = document.getElementById('taskTableBody');
    if (!tbody) return;

    if (!tasks.length) {
        tbody.innerHTML = `
            <tr>
                <td colspan="11" class="text-center text-muted py-3">No tasks found for current filters.</td>
            </tr>
        `;
        return;
    }

    tbody.innerHTML = tasks.map(t => {
        const id = pick(t, ['task_id', 'TaskID'], '---');
        const title = pick(t, ['title', 'Title'], 'Untitled');
        const projectName = pick(t, ['project_name', 'ProjectName'], '---');
        const parentTitle = pick(t, ['parent_task_title', 'ParentTaskTitle'], '---');
        const parentId = pick(t, ['parent_task_id', 'ParentTaskID'], null);
        const priority = pick(t, ['task_priority', 'TaskPriority'], 0);
        const assignee = pick(t, ['assignee_name', 'AssigneeName'], 'Unassigned');
        const reporter = pick(t, ['reporter_name', 'ReporterName'], 'Unknown');
        const status = pick(t, ['status_name', 'StatusName'], 'Unknown');
        const dueDate = formatDate(pick(t, ['due_date', 'DueDate'], null));
        const createdAt = formatDate(pick(t, ['creation_time', 'CreationTime'], null));

        const parentDisplay = parentId ? `#${parentId} - ${parentTitle}` : '---';

        return `
            <tr class="priority-${priority}">
                <td>${id}</td>
                <td><strong>${title}</strong></td>
                <td>${projectName}</td>
                <td>${parentDisplay}</td>
                <td>${priority}</td>
                <td>${assignee}</td>
                <td><span class="badge bg-info">${status}</span></td>
                <td><small>${dueDate}</small></td>
                <td>${reporter}</td>
                <td><small>${createdAt}</small></td>
                <td>
                    <button class="btn btn-sm btn-outline-warning" onclick="editTask(${id})">Edit</button>
                    <button class="btn btn-sm btn-outline-danger" onclick="deleteTask(${id})">Delete</button>
                </td>
            </tr>
        `;
    }).join('');

    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        const oldTooltip = bootstrap.Tooltip.getInstance(tooltipTriggerEl);
        if (oldTooltip) oldTooltip.dispose();
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
}

function applyFilters() {
    loadTasks();
}

function resetFilters() {
    const projectFilter = document.getElementById('projectFilter');
    const statusFilter = document.getElementById('statusFilter');
    const searchInput = document.getElementById('searchInput');

    if (projectFilter) projectFilter.value = '';
    if (statusFilter) statusFilter.value = '';
    if (searchInput) searchInput.value = '';

    loadTasks();
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
    const titleVal = document.getElementById('title').value.trim();
    const projectVal = document.getElementById('projectId').value.trim();
    // const reporterVal = document.getElementById('reporterId').value;
    if (!titleVal) {
        alert("Task title cannot empty!");
        return;
    }
    if (!projectVal) {
        alert("Project title cannot empty!");
        return;
    }
    const data = {
        title: document.getElementById('title').value,
        task_description: document.getElementById('description').value,
        task_priority: parseInt(document.getElementById('priority').value) || 0,
        status_id: parseInt(document.getElementById('statusId').value) || 1,
        
        // Polymorphism fields
        task_type: document.getElementById('taskType').value,
        type_detail: document.getElementById('typeDetail').value || "",

        // Foreign Keys
        project_id: parseInt(document.getElementById('projectId').value),
        reporter_id: (user ? user.ProfileID : 1),
        assignee_id: parseInt(document.getElementById('assigneeId').value) || null,
        milestone_id: parseInt(document.getElementById('milestoneId').value) || null,
        
        // Date field
        due_date: document.getElementById('dueDate').value || null,
        parent_task_id: parseInt(document.getElementById('parentTaskId').value) || null
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
         alert("Error: " + (error.detail || error.message || JSON.stringify(error)));

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

        if (!container) return;

        if (!data.length) {
            container.innerHTML = '<div class="col-12 text-muted">No milestone data available.</div>';
            return;
        }

        container.innerHTML = data.map(m => {
            const name = pick(m, ['milestone_name', 'MilestoneName'], 'Unnamed Milestone');
            const progressRaw = pick(m, ['progress', 'Progress'], 0);
            const progress = Number(progressRaw) || 0;
            const dueDate = pick(m, ['end_date', 'EndDate'], null);
            const formattedDate = formatDate(dueDate);

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

async function loadPerformanceReport() {
    const projectId = document.getElementById('performanceProjectId')?.value;
    const minTasks = document.getElementById('performanceMinTasks')?.value || '0';
    const tableBody = document.getElementById('performanceTableBody');

    if (!tableBody) return;

    if (!projectId) {
        alert('Please enter a Project ID to load performance report.');
        return;
    }

    try {
        const response = await fetch(`${API_URL}/reports/performance?project_id=${projectId}&min_tasks=${minTasks}`);
        if (!response.ok) {
            const err = await response.json();
            throw new Error(err.detail || 'Failed to fetch performance report');
        }

        const data = await response.json();
        if (!data.length) {
            tableBody.innerHTML = `
                <tr>
                    <td colspan="5" class="text-center text-muted py-3">No performance data found.</td>
                </tr>
            `;
            return;
        }

        tableBody.innerHTML = data.map((item) => {
            const staffName = pick(item, ['staff_name', 'StaffName'], 'Unknown');
            const projectName = pick(item, ['project_name', 'ProjectName'], '---');
            const totalTasks = Number(pick(item, ['total_tasks_assigned', 'TotalTasksAssigned'], 0)) || 0;
            const completedTasks = Number(pick(item, ['completed_tasks', 'CompletedTasks'], 0)) || 0;
            const completionRate = totalTasks > 0 ? ((completedTasks / totalTasks) * 100).toFixed(1) : '0.0';

            return `
                <tr>
                    <td>${staffName}</td>
                    <td>${projectName}</td>
                    <td>${totalTasks}</td>
                    <td>${completedTasks}</td>
                    <td>${completionRate}%</td>
                </tr>
            `;
        }).join('');
    } catch (err) {
        tableBody.innerHTML = `
            <tr>
                <td colspan="5" class="text-center text-danger py-3">${err.message}</td>
            </tr>
        `;
    }
}

async function loadStaffReport(profileIdArg = null) {
    const profileInput = document.getElementById('staffProfileId');
    const container = document.getElementById('staffReportContainer');
    const profileId = profileIdArg || profileInput?.value;

    if (!container) return;

    if (!profileId) {
        container.innerHTML = '<div class="col-12 text-muted">Enter profile ID to load staff report.</div>';
        return;
    }

    try {
        const response = await fetch(`${API_URL}/reports/staff/${profileId}`);
        if (!response.ok) {
            const err = await response.json();
            throw new Error(err.detail || 'Failed to fetch staff report');
        }

        const data = await response.json();
        const fullName = pick(data, ['FullName', 'full_name'], 'Unknown');
        const overdueCount = pick(data, ['OverdueCount', 'overdue_count'], 0);
        const status = pick(data, ['AccountStatus', 'account_status'], 'Unknown');
        const profile = pick(data, ['ProfileID', 'profile_id'], profileId);

        container.innerHTML = `
            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body">
                        <h6 class="text-muted mb-1">Full Name</h6>
                        <h5 class="fw-bold mb-0">${fullName}</h5>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body">
                        <h6 class="text-muted mb-1">Profile ID</h6>
                        <h4 class="fw-bold mb-0">${profile}</h4>
                    </div>
                </div>
            </div>
            <div class="col-md-4 mb-3">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body">
                        <h6 class="text-muted mb-1">Overdue Tasks</h6>
                        <h4 class="fw-bold mb-0 text-danger">${overdueCount}</h4>
                    </div>
                </div>
            </div>
            <div class="col-12">
                <div class="alert alert-info mb-0">Account Status: <strong>${status}</strong></div>
            </div>
        `;
    } catch (err) {
        container.innerHTML = `<div class="col-12 text-danger">${err.message}</div>`;
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
        document.getElementById('taskId').value = pick(task, ['task_id', 'TaskID'], '');
        document.getElementById('title').value = pick(task, ['title', 'Title'], '');
        document.getElementById('description').value = pick(task, ['task_description', 'TaskDescription'], '');
        document.getElementById('priority').value = pick(task, ['task_priority', 'TaskPriority'], 0);
        document.getElementById('statusId').value = pick(task, ['status_id', 'StatusID'], 1);
        document.getElementById('assigneeId').value = pick(task, ['assignee_id', 'AssigneeID'], '');
        document.getElementById('milestoneId').value = pick(task, ['milestone_id', 'MilestoneID'], '');
        document.getElementById('parentTaskId').value = pick(task, ['parent_task_id', 'ParentTaskID'], '');

        const dueDateRaw = pick(task, ['due_date', 'DueDate'], null);
        if (dueDateRaw) {
            const date = new Date(dueDateRaw);
            if (!Number.isNaN(date.getTime())) {
                document.getElementById('dueDate').value = date.toISOString().slice(0, 16);
            }
        }
        
        document.getElementById('modalTitle').innerText = 'Edit Task';
        taskModal.show();
    } catch (err) {
        alert('Failed to load task details');
    }
}