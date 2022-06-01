import { NavLink } from 'react-router-dom';

const Item = ({ name, route, className }) => (
    <li className="navbar__nav--item">
        <NavLink
            to={route}
            className={({ isActive }) => (
                `navbar__nav--${isActive ? 'active' : 'link'} non-link ${className}`
            )}
        >
            {name}
        </NavLink>
    </li>
)

export default Item;