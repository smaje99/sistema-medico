import { Helmet } from 'react-helmet';
import { Link } from 'react-router-dom'

import ForgotPasswordForm from './ForgotPasswordForm';

import routes from '@Helpers/routes';

import './styles.css';

const ForgotPassword = () => {
    return (
        <>
        <Helmet>
            <title>¿Olvidaste tu contraseña? | Sistema Médico</title>
        </Helmet>
        <main className="forgot-password">
            <section className="forgot-password__container">
                <span className="forgot-password__title">
                    ¿Olvidaste tu contraseña?
                </span>
                <ForgotPasswordForm />
                <Link to={routes.login} className="forgot-password__back non-link">
                    Volver al inicio de sesión
                </Link>
            </section>
        </main>
        </>
    )
}

export default ForgotPassword;