import { NavLink } from 'react-router-dom';

import routes from '@Helpers/routes';

import './styles.css'

const PublicNavigation = () => {
    return (
        <nav className="navbar">
            <NavLink to={routes.home} className="navbar__brand non-link">
                Sistemas Médico
            </NavLink>
            <ul className="navbar__nav non-list">
                <li className="navbar__nav--item">
                    <NavLink
                        to={routes.appointment}
                        className="navbar__nav--link non-link"
                    >
                        Agendar cita
                    </NavLink>
                </li>
                <li className="navbar__nav--item">
                    <NavLink
                        to={routes.consult}
                        className="navbar__nav--link non-link"
                    >
                        Consultar cita
                    </NavLink>
                </li>
                <li className="navbar__nav--item">
                    <div className="vertical-separator"></div>
                </li>
                <li className="navbar__nav--item">
                    <NavLink
                        to={routes.login}
                        className="navbar__nav--link non-link navbar__nav--login"
                    >
                        Iniciar sesión
                    </NavLink>
                </li>
            </ul>
        </nav>
    )
}

export default PublicNavigation;