import { Helmet } from 'react-helmet';
import { Link } from 'react-router-dom';

import LoginForm from './LoginForm';

import routes from '@Helpers/routes';

import './styles.css';

const Login = () => (
    <>
    <Helmet>
        <title>Iniciar sesión | Sistema Médico</title>
    </Helmet>
    <main className="login">
        <section className="login__container">
            <span className="login__title">Iniciar sesión</span>
            <LoginForm />
            <Link to={routes.forget_password} className="login__forget non-link">
                ¿Olvidaste tu contraseña?
            </Link>
        </section>
    </main>
    </>
)

export default Login;