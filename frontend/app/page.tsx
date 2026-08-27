"use client";

import { FormEvent, useEffect, useMemo, useState } from "react";
import {
  apiRequest,
  AuthResponse,
  EligibilityResponse,
  ProgressResponse
} from "../lib/api";

type Session = {
  token: string;
  fullName: string;
  email: string;
  role: string;
};

const emptyProgress: ProgressResponse = {
  currentCgpa: 0,
  totalCreditsCompleted: 0,
  totalSemestersCompleted: 0,
  history: []
};

export default function Home() {
  const [session, setSession] = useState<Session | null>(null);
  const [email, setEmail] = useState("student@degreeplus.test");
  const [password, setPassword] = useState("password123");
  const [progress, setProgress] = useState<ProgressResponse>(emptyProgress);
  const [eligibility, setEligibility] = useState<EligibilityResponse[]>([]);
  const [selectedCourse, setSelectedCourse] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const saved = localStorage.getItem("degreeplus-session");
    if (saved) {
      setSession(JSON.parse(saved) as Session);
    }
  }, []);

  useEffect(() => {
    if (!session) {
      return;
    }
    loadDashboard(session.token);
  }, [session]);

  const eligibleCount = useMemo(
    () => eligibility.filter((course) => course.eligible).length,
    [eligibility]
  );

  async function login(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setLoading(true);
    setMessage("");
    try {
      const auth = await apiRequest<AuthResponse>("/api/auth/login", {
        method: "POST",
        body: JSON.stringify({ email, password })
      });
      const nextSession = {
        token: auth.token,
        fullName: auth.fullName,
        email: auth.email,
        role: auth.role
      };
      localStorage.setItem("degreeplus-session", JSON.stringify(nextSession));
      setSession(nextSession);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Login failed.");
    } finally {
      setLoading(false);
    }
  }

  async function loadDashboard(token: string) {
    setLoading(true);
    setMessage("");
    try {
      const [progressData, eligibilityData] = await Promise.all([
        apiRequest<ProgressResponse>("/api/students/me/progress", {}, token),
        apiRequest<EligibilityResponse[]>("/api/eligibility/courses", {}, token)
      ]);
      setProgress(progressData);
      setEligibility(eligibilityData);
      setSelectedCourse(eligibilityData[0]?.courseCode ?? "");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Unable to load dashboard.");
    } finally {
      setLoading(false);
    }
  }

  async function addAttempt(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!session || !selectedCourse) {
      return;
    }

    const form = new FormData(event.currentTarget);
    setLoading(true);
    setMessage("");
    try {
      const updated = await apiRequest<ProgressResponse>(
        "/api/students/me/course-attempts",
        {
          method: "POST",
          body: JSON.stringify({
            courseCode: selectedCourse,
            semesterName: form.get("semesterName"),
            obtainedGrade: form.get("obtainedGrade"),
            gradePoint: Number(form.get("gradePoint")),
            creditsEarned: Number(form.get("creditsEarned")),
            completed: true
          })
        },
        session.token
      );
      setProgress(updated);
      const eligibilityData = await apiRequest<EligibilityResponse[]>(
        "/api/eligibility/courses",
        {},
        session.token
      );
      setEligibility(eligibilityData);
      event.currentTarget.reset();
      setMessage("Course attempt saved.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Could not save course attempt.");
    } finally {
      setLoading(false);
    }
  }

  function logout() {
    localStorage.removeItem("degreeplus-session");
    setSession(null);
    setProgress(emptyProgress);
    setEligibility([]);
  }

  if (!session) {
    return (
      <main className="min-h-screen px-4 py-10">
        <section className="mx-auto max-w-sm">
          <h1 className="text-2xl font-semibold tracking-normal">DegreePlus</h1>
          <p className="mt-2 text-sm text-gray-600">Academic progress and eligibility tracker</p>

          <form onSubmit={login} className="mt-8 space-y-4 rounded border border-gray-200 bg-white p-5">
            <label className="block">
              <span className="text-sm font-medium text-gray-700">Email</span>
              <input
                className="mt-1 w-full rounded border border-gray-300 px-3 py-2 outline-none focus:border-gray-900"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                type="email"
              />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-gray-700">Password</span>
              <input
                className="mt-1 w-full rounded border border-gray-300 px-3 py-2 outline-none focus:border-gray-900"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                type="password"
              />
            </label>
            <button
              className="w-full rounded bg-gray-950 px-3 py-2 text-sm font-medium text-white disabled:bg-gray-400"
              disabled={loading}
              type="submit"
            >
              {loading ? "Signing in..." : "Sign in"}
            </button>
            {message && <p className="text-sm text-red-600">{message}</p>}
          </form>
        </section>
      </main>
    );
  }

  return (
    <main className="min-h-screen px-4 py-6">
      <section className="mx-auto max-w-6xl">
        <header className="flex flex-wrap items-center justify-between gap-3 border-b border-gray-200 pb-4">
          <div>
            <h1 className="text-2xl font-semibold tracking-normal">DegreePlus</h1>
            <p className="text-sm text-gray-600">{session.fullName} - {session.email}</p>
          </div>
          <button className="rounded border border-gray-300 px-3 py-2 text-sm" onClick={logout}>
            Logout
          </button>
        </header>

        {message && (
          <p className="mt-4 rounded border border-gray-200 bg-white px-3 py-2 text-sm text-gray-700">
            {message}
          </p>
        )}

        <section className="mt-6 grid gap-3 md:grid-cols-4">
          <Metric label="Current CGPA" value={progress.currentCgpa.toFixed(2)} />
          <Metric label="Completed Credits" value={progress.totalCreditsCompleted.toString()} />
          <Metric label="Semesters Completed" value={progress.totalSemestersCompleted.toString()} />
          <Metric label="Eligible Courses" value={`${eligibleCount}/${eligibility.length}`} />
        </section>

        <section className="mt-6 grid gap-6 lg:grid-cols-[1.15fr_0.85fr]">
          <div className="rounded border border-gray-200 bg-white">
            <div className="border-b border-gray-200 px-4 py-3">
              <h2 className="font-medium">Course History</h2>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead className="bg-gray-50 text-gray-600">
                  <tr>
                    <th className="px-4 py-2 font-medium">Course</th>
                    <th className="px-4 py-2 font-medium">Semester</th>
                    <th className="px-4 py-2 font-medium">Attempt</th>
                    <th className="px-4 py-2 font-medium">Grade</th>
                    <th className="px-4 py-2 font-medium">Credits</th>
                  </tr>
                </thead>
                <tbody>
                  {progress.history.map((attempt) => (
                    <tr className="border-t border-gray-100" key={attempt.recordId}>
                      <td className="px-4 py-3">
                        <div className="font-medium">{attempt.courseCode}</div>
                        <div className="text-xs text-gray-500">{attempt.courseTitle}</div>
                      </td>
                      <td className="px-4 py-3">{attempt.semesterName}</td>
                      <td className="px-4 py-3">{attempt.attemptNumber}</td>
                      <td className="px-4 py-3">{attempt.obtainedGrade} ({attempt.gradePoint})</td>
                      <td className="px-4 py-3">{attempt.creditsEarned}</td>
                    </tr>
                  ))}
                  {progress.history.length === 0 && (
                    <tr>
                      <td className="px-4 py-6 text-gray-500" colSpan={5}>
                        No academic history yet.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>

          <div className="space-y-6">
            <form onSubmit={addAttempt} className="rounded border border-gray-200 bg-white p-4">
              <h2 className="font-medium">Add Course Attempt</h2>
              <div className="mt-4 grid gap-3">
                <label className="block">
                  <span className="text-sm text-gray-700">Course</span>
                  <select
                    className="mt-1 w-full rounded border border-gray-300 px-3 py-2"
                    value={selectedCourse}
                    onChange={(event) => setSelectedCourse(event.target.value)}
                  >
                    {eligibility.map((course) => (
                      <option key={course.courseCode} value={course.courseCode}>
                        {course.courseCode} - {course.courseTitle}
                      </option>
                    ))}
                  </select>
                </label>
                <input className="rounded border border-gray-300 px-3 py-2" name="semesterName" placeholder="Semester, e.g. Spring 2026" required />
                <input className="rounded border border-gray-300 px-3 py-2" name="obtainedGrade" placeholder="Grade, e.g. A-" required />
                <input className="rounded border border-gray-300 px-3 py-2" max="4" min="0" name="gradePoint" placeholder="Grade point" required step="0.01" type="number" />
                <input className="rounded border border-gray-300 px-3 py-2" min="0" name="creditsEarned" placeholder="Credits earned" required step="0.01" type="number" />
                <button
                  className="rounded bg-gray-950 px-3 py-2 text-sm font-medium text-white disabled:bg-gray-400"
                  disabled={loading}
                  type="submit"
                >
                  Save Attempt
                </button>
              </div>
            </form>

            <div className="rounded border border-gray-200 bg-white">
              <div className="border-b border-gray-200 px-4 py-3">
                <h2 className="font-medium">Eligibility</h2>
              </div>
              <div className="divide-y divide-gray-100">
                {eligibility.map((course) => (
                  <div className="px-4 py-3" key={course.courseCode}>
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <div className="font-medium">{course.courseCode}</div>
                        <div className="text-sm text-gray-600">{course.courseTitle}</div>
                      </div>
                      <span className={course.eligible ? "text-sm text-green-700" : "text-sm text-red-700"}>
                        {course.eligible ? "Eligible" : "Blocked"}
                      </span>
                    </div>
                    <p className="mt-2 text-sm text-gray-600">{course.messages.join(" ")}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>
      </section>
    </main>
  );
}

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded border border-gray-200 bg-white px-4 py-3">
      <div className="text-sm text-gray-600">{label}</div>
      <div className="mt-1 text-2xl font-semibold tracking-normal">{value}</div>
    </div>
  );
}
