import { Outlet } from 'react-router-dom';

import { PrivateNavigation } from '@Components/Navigation';

const PrivateLayout = () => (
    <div className="layout--private">
        <PrivateNavigation />
        <Outlet />
    </div>
)

export default PrivateLayout;