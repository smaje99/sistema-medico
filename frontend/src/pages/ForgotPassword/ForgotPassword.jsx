import { Helmet } from 'react-helmet';

import ForgotPasswordForm from './ForgotPasswordForm';

import './styles.css';

const ForgotPassword = () => {
    return (
        <>
        <Helmet>
            <title>¿Olvidaste tu contraseña? | Sistema Médico</title>
        </Helmet>
        <section className="forgot-password">
            <span className="forgot-password__title">
                ¿Olvidaste tu contraseña?
            </span>
            <ForgotPasswordForm />
        </section>
        </>
    )
}

export default ForgotPassword;