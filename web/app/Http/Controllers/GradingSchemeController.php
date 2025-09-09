<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class GradingSchemeController extends Controller
{
    public function index()
    {
        // load real data here; fallback handled in view
        return view('admin.grading-scheme');
    }

    public function store(Request $request)
    {
        // basic validation example
        $data = $request->validate([
            'department' => 'required|string',
            'components' => 'nullable|array',
            'components.*.name' => 'required_with:components|string',
            'components.*.weight' => 'required_with:components|numeric|min:0|max:100',
        ]);

        // TODO: persist $data to DB (create/update grading scheme)
        // Example: GradingScheme::updateOrCreate(...)

        return redirect()->route('grading.scheme')->with('status', 'Grading scheme saved.');
    }
}