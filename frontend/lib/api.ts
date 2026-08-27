export const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8080";

export type AuthResponse = {
  token: string;
  userId: number;
  fullName: string;
  email: string;
  role: string;
};

export type CourseAttempt = {
  recordId: number;
  courseCode: string;
  courseTitle: string;
  semesterName: string;
  attemptNumber: number;
  obtainedGrade: string;
  gradePoint: number;
  creditsEarned: number;
  completed: boolean;
};

export type ProgressResponse = {
  currentCgpa: number;
  totalCreditsCompleted: number;
  totalSemestersCompleted: number;
  history: CourseAttempt[];
};

export type EligibilityResponse = {
  courseCode: string;
  courseTitle: string;
  eligible: boolean;
  completedCredits: number;
  minCreditsRequired: number;
  missingPrerequisites: string[];
  messages: string[];
};

export async function apiRequest<T>(
  path: string,
  options: RequestInit = {},
  token?: string
): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options.headers
    }
  });

  if (!response.ok) {
    const body = await response.json().catch(() => ({ message: "Request failed." }));
    throw new Error(body.message ?? "Request failed.");
  }

  return response.json() as Promise<T>;
}
