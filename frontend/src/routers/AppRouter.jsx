import { Routes, Route } from 'react-router-dom';

import { PrivateLayout, PublicLayout } from '@Components/Layout';

import Home from '@Pages/Home';
import Login from '@Pages/Login';
import Who from '@Pages/Who';
import ForgotPassword from '@Pages/ForgotPassword';

import React from 'react'

const AppRouter = () => (
    <Routes>
        <Route path="/">
            <Route element={<PublicLayout />}>
                <Route index element={<Home />} />
                <Route path="login" element={<Login />} />
                <Route path="who" element={<Who />} />
                <Route path="forgot-password" element={<ForgotPassword />} />

                <Route path="*" element={<h1>Página no encontrada</h1>} />
            </Route>
        </Route>
    </Routes>
)

export default AppRouter