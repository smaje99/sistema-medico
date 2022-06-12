import { useForm } from 'react-hook-form';
import { FaUser  } from 'react-icons/fa';

const ForgotPasswordForm = () => {
    const {
        reset,
        register,
        handleSubmit,
        formState: { errors }
    } = useForm();

    const handleForgotPassword = (formData) => {}

    return (
        <form
            className="forgot-password__form"
            onSubmit={handleSubmit(handleForgotPassword)}
        >
            <label
                htmlFor="forgot-password-username"
                className="forgot-password__form__content"
            >
                <FaUser />
                <input
                    type="text"
                    id="forgot-password-username"
                    className="forgot-password__form--input"
                    placeholder="Ingrese su usuario"
                    { ...register('username') }
                />
            </label>
            <input
                type="submit"
                className="forgot-password__form--submit button-round"
                value="Recuperar contraseña"
            />
        </form>
    )
}

export default ForgotPasswordForm;