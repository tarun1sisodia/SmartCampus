"use client";

import { ChangeEvent, useMemo, useState } from "react";
import Papa from "papaparse";
import { useMutation } from "@tanstack/react-query";
import { importStudents } from "@/lib/api/endpoints/student-api";
import { useToast } from "@/components/ui/Toast";

type CsvRow = Record<string, string>;

const requiredFields = [
  "rollNumber",
  "name",
  "email",
  "course",
  "semester",
  "section",
  "contact",
  "parentContact"
];

export default function ImportStudentsPage() {
  const { showToast } = useToast();
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [rows, setRows] = useState<CsvRow[]>([]);
  const [parseError, setParseError] = useState<string | null>(null);

  const mutation = useMutation({
    mutationFn: importStudents,
    onSuccess: (result) => {
      showToast(
        `Import completed. Success: ${result.succeeded}, Failed: ${result.failed}`,
        "success"
      );
    },
    onError: () => showToast("Student import failed", "error")
  });

  const handleFileSelect = (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0] ?? null;
    setParseError(null);
    setRows([]);
    setSelectedFile(file);

    if (!file) return;

    Papa.parse<CsvRow>(file, {
      header: true,
      skipEmptyLines: true,
      complete: results => {
        setRows(results.data.slice(0, 5));
      },
      error: () => {
        setParseError("Unable to parse file. Please check CSV format.");
      }
    });
  };

  const mappedColumns = useMemo(() => {
    if (!rows.length) return [];
    return Object.keys(rows[0]);
  }, [rows]);

  const handleImport = async () => {
    if (!selectedFile) {
      showToast("Select a file before importing", "warning");
      return;
    }
    await mutation.mutateAsync(selectedFile);
  };

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Import Students</h1>

      <div className="rounded-lg border border-dashed border-slate-300 bg-white p-4">
        <p className="mb-2 text-sm text-textSecondary">Upload `.csv` or `.xlsx` file</p>
        <input type="file" accept=".csv,.xlsx" onChange={handleFileSelect} />
        {parseError && <p className="mt-2 text-sm text-danger">{parseError}</p>}
      </div>

      <div className="rounded-lg border border-slate-200 bg-white p-4">
        <p className="mb-2 text-sm font-medium">Column Mapping (detected headers)</p>
        {mappedColumns.length ? (
          <div className="flex flex-wrap gap-2">
            {mappedColumns.map(column => (
              <span
                key={column}
                className={`rounded px-2 py-1 text-xs ${
                  requiredFields.includes(column)
                    ? "bg-success/15 text-success"
                    : "bg-slate-100 text-textSecondary"
                }`}
              >
                {column}
              </span>
            ))}
          </div>
        ) : (
          <p className="text-sm text-textSecondary">No headers detected yet.</p>
        )}
      </div>

      <div className="rounded-lg border border-slate-200 bg-white p-4">
        <p className="mb-2 text-sm font-medium">Preview (first 5 rows)</p>
        {!rows.length ? (
          <p className="text-sm text-textSecondary">No preview available.</p>
        ) : (
          <div className="overflow-auto">
            <table className="min-w-full text-sm">
              <thead>
                <tr className="border-b border-slate-200">
                  {Object.keys(rows[0]).map(column => (
                    <th key={column} className="px-3 py-2 text-left">
                      {column}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {rows.map((row, index) => (
                  <tr key={`row-${index}`} className="border-b border-slate-100">
                    {Object.keys(rows[0]).map(column => (
                      <td key={`${index}-${column}`} className="px-3 py-2">
                        {row[column] ?? ""}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <div>
        <button
          disabled={mutation.isPending}
          onClick={handleImport}
          className="rounded bg-primary px-3 py-2 text-sm text-white disabled:opacity-70"
        >
          {mutation.isPending ? "Importing..." : "Import Students"}
        </button>
      </div>
    </div>
  );
}
