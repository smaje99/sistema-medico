import { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { FaEye, FaEyeSlash, FaUser, FaUserLock } from 'react-icons/fa';
import { useLocation } from 'react-router-dom';
import { toast } from 'react-toastify';

import config from '@Helpers/config';
import routes from '@Helpers/routes';

const LoginForm = () => {
    const [isShowPassword, setShowPassword] = useState(false);

    const {
        reset,
        register,
        handleSubmit,
        formState: { errors }
    } = useForm();

    const location = useLocation();

    const handleLogin = (formData) => {};

    const handleShowPassword = (event) => {
        event.preventDefault();
        setShowPassword(show => !show);
    }

    /* Resetting the form when the component is mounted. */
    useEffect(reset, []);

    /* List the errors in the form */
    useEffect(() => {
        Object.values(errors)
            .forEach(({ message }) => toast.warning(message, config.toast))
    }, [errors]);

    return (
        <form className="login-form" onSubmit={handleSubmit(handleLogin)}>
            <label htmlFor="login-username" className="login-form__content">
                <FaUser />
                <input
                    type="text"
                    id="login-username"
                    className="login__login__input"
                    placeholder="Usuario"
                    { ...register('username') }
                />
            </label>
            <label htmlFor="login-password" className="login-form__content">
                <FaUserLock />
                <input
                    type={ isShowPassword ? 'text': 'password' }
                    id="login-password"
                    className="login__login__input"
                    placeholder="Contraseña"
                    { ...register('password') }
                />
                <button
                    className="login-form--show"
                    onClick={handleShowPassword}
                >
                    { isShowPassword ? <FaEye /> : <FaEyeSlash /> }
                </button>
            </label>

            <input
                type="submit"
                className="login-form__input button-round"
                value="Iniciar sesión"
            />
        </form>
    )
}

export default LoginForm