<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ChecklistController extends Controller
{
    public function forStudent(Request $request, $studid = null)
    {
        $id = $studid ?? $request->query('student_id');
        if (empty($id)) {
            return response()->json(['error' => 'student id required'], 400);
        }

        $rows = DB::table('studsubjfeealignment')
            ->where('StudID', $id)
            ->select('Term', 'SchoolYear', 'SubjectID', 'Units')
            ->get();

        return response()->json($rows);
    }
}