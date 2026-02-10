import { Component, type ReactNode } from "react";

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error("ErrorBoundary caught error:", error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback || (
          <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-black">
            <div className="bg-red-900/90 border-2 border-red-500 text-red-200 px-8 py-6 rounded-lg max-w-md mx-4">
              <h2 className="text-2xl font-bold mb-4">Something went wrong</h2>
              <p className="mb-4">{this.state.error?.message || "An unexpected error occurred"}</p>
              <button
                onClick={() => window.location.reload()}
                className="bg-red-800 hover:bg-red-700 text-red-100 px-4 py-2 rounded-lg transition-colors font-bold"
              >
                Reload Page
              </button>
            </div>
          </div>
        )
      );
    }

    return this.props.children;
  }
}
