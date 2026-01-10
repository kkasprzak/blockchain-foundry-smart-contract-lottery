import { useState } from 'react'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
      <div className="max-w-2xl mx-auto p-8">
        <div className="bg-white rounded-2xl shadow-xl p-8 space-y-6">
          <h1 className="text-4xl font-bold text-gray-900 text-center">
            Raffle DApp
          </h1>

          <p className="text-gray-600 text-center">
            Vite + React + TypeScript + Tailwind CSS v4
          </p>

          <div className="flex justify-center">
            <button
              onClick={() => setCount((count) => count + 1)}
              className="bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-3 px-6 rounded-lg transition-colors duration-200 shadow-md hover:shadow-lg"
            >
              Count is {count}
            </button>
          </div>

          <div className="mt-6 p-4 bg-green-50 border border-green-200 rounded-lg">
            <p className="text-green-800 text-center font-medium">
              ✅ Tailwind CSS v4 is working!
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App
