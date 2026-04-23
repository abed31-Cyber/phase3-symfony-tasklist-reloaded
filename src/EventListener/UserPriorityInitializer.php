<?php

namespace App\EventListener;

use App\Entity\User;
use App\Entity\Priority;
use Doctrine\ORM\Events;
use Doctrine\Bundle\DoctrineBundle\Attribute\AsEntityListener;
use Doctrine\ORM\EntityManagerInterface;

#[AsEntityListener(event: Events::postPersist, entity: User::class)]
class UserPriorityInitializer
{
    public function __construct(private EntityManagerInterface $entityManager)
    {
    }

    public function postPersist(User $user): void
    {
        // Créer les 3 priorités par défaut
        $defaultPriorities = ['urgent', 'important', 'normal'];

        foreach ($defaultPriorities as $level) {
            $priority = new Priority();
            $priority->setLevel($level);
            $priority->setOwner($user);
            
            $this->entityManager->persist($priority);
        }

        $this->entityManager->flush();
    }
}
