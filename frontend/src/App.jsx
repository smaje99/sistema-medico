import { BrowserRouter as Router } from 'react-router-dom';
import { ToastContainer } from 'react-toastify';

import AppRouter from '@Routers/AppRouter';

const App = () => (
    <>
    <Router>
        <AppRouter />
    </Router>
    <ToastContainer />
    </>
)

export default App;