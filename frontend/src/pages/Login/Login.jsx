import { Helmet } from 'react-helmet';
import LoginForm from './LoginForm';

import './styles.css';

const Login = () => (
    <>
    <Helmet>
        <title>Iniciar sesión | Sistema Médico</title>
    </Helmet>
    <main className="login">
        <LoginForm />
    </main>
    </>
)

export default Login;