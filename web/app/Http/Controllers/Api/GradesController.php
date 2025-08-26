<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class GradesController extends Controller
{
    public function index(Request $request)
    {
        $request->validate([
            'student_id' => 'required|string',
            'year' => 'nullable|string',
        ]);

        $studentId = $request->input('student_id');
        $year = $request->input('year');

        try {
            $query = DB::table('termgrades')->where('StudID', $studentId);

            if ($year) {
                $query->where(function ($q) use ($year) {
                    $q->where('SchoolYear', $year)
                      ->orWhere('AcademicYear', $year)
                      ->orWhere('AY', $year);
                });
            }

            $rows = $query->get();

            // group by SchoolYear -> Term (map common term values to friendly labels)
            $out = [];
            foreach ($rows as $r) {
                $ay = $r->SchoolYear ?? $r->AcademicYear ?? $r->AY ?? ($year ?? 'Unknown');
                $rawTerm = (string) ($r->Term ?? $r->term ?? '');
                $term = $this->mapTermLabel($rawTerm);

                if (! isset($out[$ay])) $out[$ay] = [];
                if (! isset($out[$ay][$term])) $out[$ay][$term] = [];

                $out[$ay][$term][] = [
                    'subject' => $r->CodeNumber ?? $r->Course ?? $r->Subject ?? '',
                    'prelim'  => $this->formatGrade($r->PrelimGrade ?? $r->Prelim ?? $r->prelim ?? null),
                    'midterm' => $this->formatGrade($r->MidtermGrade ?? $r->Midterm ?? $r->midterm ?? null),
                    'finals'  => $this->formatGrade($r->FinalsGrade ?? $r->Finals ?? $r->finals ?? null),
                    // keep raw final if present
                    'final'   => $this->formatGrade($r->Final ?? $r->final ?? null),
                ];
            }

            return response()->json(['status' => 'success', 'data' => $out], 200);
        } catch (\Throwable $e) {
            Log::error('Grades fetch error: ' . $e->getMessage());
            return response()->json(['status' => 'error', 'message' => 'Server error'], 500);
        }
    }

    private function mapTermLabel(string $term): string
    {
        $t = strtolower(trim($term));
        if ($t === '' || $t === 'unknown') return 'Unknown Semester';
        if (in_array($t, ['1-sem','1-semester','1st-sem','1st','first','first sem','first-sem','1'], true)) {
            return 'First Semester';
        }
        if (in_array($t, ['2-sem','2-semester','2nd-sem','2nd','second','second sem','second-sem','2'], true)) {
            return 'Second Semester';
        }
        // fallback: return original term string nicely capitalized
        return ucwords(str_replace(['-', '_'], ' ', $term));
    }

    private function formatGrade($g): ?string
    {
        if ($g === null || $g === '') return null;
        // keep numeric formatting consistent
        if (is_numeric($g)) {
            // remove trailing .00 for whole numbers, otherwise show up to 2 decimals
            $val = (float)$g;
            if (floor($val) == $val) return (string)((int)$val);
            return number_format($val, 2, '.', '');
        }
        return (string)$g;
    }
}