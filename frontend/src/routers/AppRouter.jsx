import { Routes, Route } from 'react-router-dom';

import { PrivateLayout, PublicLayout } from '@Components/Layout';

import Home from '@Pages/Home';
import Who from '@Pages/Who';

import React from 'react'

const AppRouter = () => (
    <Routes>
        <Route path="/">
            <Route element={<PublicLayout />}>
                <Route index element={<Home />} />
                <Route path="who" element={<Who />} />

                <Route path="*" element={<h1>Página no encontrada</h1>} />
            </Route>
        </Route>
    </Routes>
)

export default AppRouter