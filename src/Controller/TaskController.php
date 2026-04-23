<?php

namespace App\Controller;

use App\Entity\Task;
use App\Form\TaskFormType;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\CurrentUser;

final class TaskController extends AbstractController
{
    #[Route('/task/new', name: 'app_task_new')]
    public function new(Request $request, EntityManagerInterface $entityManager, #[CurrentUser()] $user): Response
    {
        $task = new Task();
        $task->setOwner($user);
        $task->setStatus(\App\Enum\Status::Pending);
        $task->setIsPinned(false);

        $form = $this->createForm(TaskFormType::class, $task, [
            'user' => $user,
        ]);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $entityManager->persist($task);
            $entityManager->flush();

            return $this->redirectToRoute('app_dashboard');
        }

        return $this->render('task/new.html.twig', [
            'form' => $form,
        ]);
    }
}
