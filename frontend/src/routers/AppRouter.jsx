import { Routes, Route } from 'react-router-dom';

import { PrivateLayout, PublicLayout } from '@Components/Layout';

import React from 'react'

const AppRouter = () => (
    <Routes>
        <Route path="/">
            <Route element={<PublicLayout />}>
                <Route index element={<h1>Sistema Médico</h1>} />

                <Route path="*" element={<h1>Página no encontrada</h1>} />
            </Route>
        </Route>
    </Routes>
)

export default AppRouter