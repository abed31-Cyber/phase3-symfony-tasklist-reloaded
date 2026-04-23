<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\CurrentUser;
use App\Entity\User;

final class DashboardController extends AbstractController
{
    #[Route('/dashboard', name: 'app_dashboard')]
    public function index(#[CurrentUser()]User $user): Response

    {
       
        $tasks = $user->getTasks();

        return $this->render('dashboard/index.html.twig', [
            'tasks' => $tasks
        ]);
    }
}
