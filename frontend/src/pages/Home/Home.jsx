import { Link } from 'react-router-dom';

import routes from '@Helpers/routes'

import './styles.css';

const Home = () => {
    return (
        <main className="home">
            <span className="home__title">
                ¡Agenda tu cita médica con nosotros!
            </span>
            <div className="home__container">
                <Link
                    to={routes.appointment}
                    className="home__link--primary non-link button-round"
                >
                    Agendar cita
                </Link>
                <Link
                    to={routes.consult}
                    className="home__link--secondary non-link button-round"
                >
                    Consultar cita
                </Link>
            </div>
        </main>
    )
}

export default Home;