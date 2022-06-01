import { NavLink } from 'react-router-dom';

import Item from './Item';

import routes from '@Helpers/routes';

import './styles.css'

const PublicNavigation = () => {
    return (
        <nav className="navbar">
            <NavLink to={routes.home} className="navbar__brand non-link">
                Sistemas Médico
            </NavLink>
            <ul className="navbar__nav non-list">
                <Item name="Agendar cita" route={routes.appointment} />
                <Item name="Consultar cita" route={routes.consult} />
                <Item name="¿Quiénes somos?" route={routes.who} />
                <li className="navbar__nav--item">
                    <div className="vertical-separator"></div>
                </li>
                <Item
                    name="Iniciar sesión"
                    route={routes.login}
                    className="navbar__nav--login button-round"
                />
            </ul>
        </nav>
    )
}

export default PublicNavigation;