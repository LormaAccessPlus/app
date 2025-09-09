@extends('components.app')

@php
    $title = 'Grading Scheme';
    // sample fallback data if controller doesn't pass variables
    $departments = $departments ?? ['Computer Science','Mathematics','Physics'];
    $schemes = $schemes ?? [
        ['dept'=>'Computer Science','components'=>4,'modified'=>'Sept 9, 2025'],
        ['dept'=>'Mathematics','components'=>5,'modified'=>'Sept 8, 2025'],
        ['dept'=>'Physics','components'=>4,'modified'=>'Sept 7, 2025'],
    ];
@endphp

@section('content')
<div class="container py-4">
    <h1 class="mb-4">Grading Scheme</h1>

    <div class="card mb-5">
        <div class="card-body">
            <form id="grading-form" method="POST" action="{{ route('grading.scheme.save') ?? '#' }}">
                @csrf

                <div class="row align-items-center mb-3">
                    <div class="col-md-8">
                        <label class="form-label">Select Department</label>
                        <select id="department" name="department" class="form-select">
                            @foreach($departments as $dept)
                                <option value="{{ $dept }}">{{ $dept }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-4 text-end">
                        <button type="button" id="new-dept" class="btn btn-primary mt-4">
                            <i class="bi bi-plus-lg"></i> New Department
                        </button>
                    </div>
                </div>

                <div id="components-list" class="mb-3">
                    <!-- existing rows will be populated here -->
                    <div class="component-row d-flex align-items-center mb-2 gap-2">
                        <input name="components[0][name]" class="form-control" placeholder="Exams" />
                        <input name="components[0][weight]" type="number" min="0" max="100" class="form-control w-25 text-end" value="40" />
                        <button type="button" class="btn btn-outline-secondary btn-sm del-component" title="Delete">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                    <div class="component-row d-flex align-items-center mb-2 gap-2">
                        <input name="components[1][name]" class="form-control" placeholder="Quizzes" />
                        <input name="components[1][weight]" type="number" min="0" max="100" class="form-control w-25 text-end" value="25" />
                        <button type="button" class="btn btn-outline-secondary btn-sm del-component" title="Delete">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                    <div class="component-row d-flex align-items-center mb-2 gap-2">
                        <input name="components[2][name]" class="form-control" placeholder="Projects" />
                        <input name="components[2][weight]" type="number" min="0" max="100" class="form-control w-25 text-end" value="20" />
                        <button type="button" class="btn btn-outline-secondary btn-sm del-component" title="Delete">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                    <div class="component-row d-flex align-items-center mb-2 gap-2">
                        <input name="components[3][name]" class="form-control" placeholder="Participation" />
                        <input name="components[3][weight]" type="number" min="0" max="100" class="form-control w-25 text-end" value="15" />
                        <button type="button" class="btn btn-outline-secondary btn-sm del-component" title="Delete">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                </div>

                <div class="mb-3">
                    <button type="button" id="add-component" class="btn btn-link p-0">
                        <i class="bi bi-plus-lg"></i> Add Component
                    </button>
                </div>

                <div class="d-flex justify-content-between align-items-center border-top pt-3">
                    <div>
                        <strong>Total:</strong> <span id="total-percent">100%</span>
                    </div>
                    <div class="d-flex gap-2">
                        <button type="button" id="reset-btn" class="btn btn-link">Reset</button>
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            Department Grading Schemes
        </div>
        <div class="card-body p-0">
            <table class="table mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Department</th>
                        <th>Components</th>
                        <th>Last Modified</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($schemes as $s)
                        <tr>
                            <td>{{ $s['dept'] }}</td>
                            <td>{{ $s['components'] }} Components</td>
                            <td>{{ $s['modified'] }}</td>
                            <td class="text-end">
                                <a href="#" class="btn btn-sm btn-outline-secondary" title="Edit"><i class="bi bi-pencil"></i></a>
                                <button class="btn btn-sm btn-outline-danger" title="Delete"><i class="bi bi-trash"></i></button>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- small inline script to manage components and total -->
@push('scripts')
<script>
(function () {
    const list = document.getElementById('components-list');
    const addBtn = document.getElementById('add-component');
    const totalEl = document.getElementById('total-percent');
    const resetBtn = document.getElementById('reset-btn');

    function updateTotal() {
        let total = 0;
        list.querySelectorAll('input[type="number"]').forEach(i => {
            total += Number(i.value) || 0;
        });
        totalEl.textContent = total + '%';
        totalEl.style.color = (total === 100) ? 'inherit' : 'crimson';
    }

    function indexRows() {
        list.querySelectorAll('.component-row').forEach((row, idx) => {
            const name = row.querySelector('input[type="text"], input:not([type])') || row.querySelector('input.form-control');
            const weight = row.querySelector('input[type="number"]');
            if (name) name.name = `components[${idx}][name]`;
            if (weight) weight.name = `components[${idx}][weight]`;
        });
    }

    function makeRow(name = '', weight = 0) {
        const row = document.createElement('div');
        row.className = 'component-row d-flex align-items-center mb-2 gap-2';
        row.innerHTML = `
            <input class="form-control" placeholder="Component name" value="${name.replace(/"/g,'&quot;')}" />
            <input type="number" min="0" max="100" class="form-control w-25 text-end" value="${weight}" />
            <button type="button" class="btn btn-outline-secondary btn-sm del-component" title="Delete">
                <i class="bi bi-trash"></i>
            </button>
        `;
        list.appendChild(row);

        row.querySelector('.del-component').addEventListener('click', function () {
            row.remove();
            indexRows();
            updateTotal();
        });
        row.querySelector('input[type="number"]').addEventListener('input', updateTotal);
        indexRows();
        updateTotal();
    }

    // wire existing delete buttons and inputs
    list.querySelectorAll('.component-row').forEach(row => {
        row.querySelector('.del-component').addEventListener('click', function () {
            row.remove();
            indexRows();
            updateTotal();
        });
        const num = row.querySelector('input[type="number"]');
        if (num) num.addEventListener('input', updateTotal);
    });

    addBtn.addEventListener('click', function () {
        makeRow('', 0);
    });

    resetBtn.addEventListener('click', function () {
        // simple reset: remove all and recreate defaults
        list.innerHTML = '';
        makeRow('Exams', 40);
        makeRow('Quizzes', 25);
        makeRow('Projects', 20);
        makeRow('Participation', 15);
    });

    // initial total calc
    updateTotal();
})();
</script>
@endpush
@endsection