import { useState, useEffect } from 'react'
import axios from 'axios'

interface Task {
  id: number
  title: string
  content: string
  published: boolean
}

function App() {
  const [newTask, setNewTask] = useState('')
  const [tasks, setTasks] = useState<Task[]>([])

  const handleAddTask = async () => {
    const response = await axios.post('http://localhost:8000/api/v1/posts', {
      title: newTask,
      content: newTask,
      published: false,
    })
    setTasks([...tasks, response.data])
    setNewTask('')
  }

  useEffect(() => {
    const fetchTasks = async () => {
      const response = await axios.get('http://localhost:8000/api/v1/posts')
      setTasks(response.data)
    }
    fetchTasks()
  }, [])

  return (
    <div className="container">
      <h1>Todo List</h1>
      <input
        type="text"
        placeholder="Enter your task"
        value={newTask}
        onChange={(e) => setNewTask(e.target.value)}
      />
      <button onClick={handleAddTask}>Add</button>
      <ul>
        {tasks.map((task) => (
          <li key={task.id}>{task.title}</li>
        ))}
      </ul>
    </div>
  )
}

export default App
