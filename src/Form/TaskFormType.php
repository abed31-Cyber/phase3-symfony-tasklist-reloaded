<?php

namespace App\Form;

use App\Entity\Folder;
use App\Entity\Priority;
use App\Entity\Task;
use App\Entity\User;
use Symfony\Bridge\Doctrine\Form\Type\EntityType;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;

class TaskFormType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $user = $options['user'];

        $builder
            ->add('title')
            ->add('priority', EntityType::class, [
                'class' => Priority::class,
                'choice_label' => 'level',
                'query_builder' => function ($repository) use ($user) {
                    return $repository->createQueryBuilder('p')
                        ->where('p.owner = :owner')
                        ->setParameter('owner', $user)
                        ->orderBy('p.level', 'ASC');
                },
            ])
            ->add('folder', EntityType::class, [
                'class' => Folder::class,
                'choice_label' => 'name',
                'required' => false,
                'query_builder' => function ($repository) use ($user) {
                    return $repository->createQueryBuilder('f')
                        ->where('f.owner = :owner')
                        ->setParameter('owner', $user)
                        ->orderBy('f.name', 'ASC');
                },
            ])
        ;
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Task::class,
            'user' => null,
        ]);
    }
}
