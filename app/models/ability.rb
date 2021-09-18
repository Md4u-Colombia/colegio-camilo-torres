class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:

    #PERFIL SUPERADMIN
    if user.role_id == 0
        can :manage, :all
        cannot [:create,:destroy], PeriodNotesDetail
        can [:read,:destroy], PeriodNotesDetail
    end

    #PERFIL ADMINISTRADOR
    if user.role_id == 1
        can [:create,:read,:update,:destroy], :all
        cannot [:create,:update,:destroy], PeriodNotesDetail
        cannot [:destroy], EducationalPerformance
        cannot [:create,:destroy], User
    end

    #PERFIL DE DOCENTE
    if user.role_id == 2
        can [:read], TeacherAsignature
        cannot [:create,:destroy], TeacherAsignature
        can [:create,:read,:update,:destroy], PeriodNotesDetail
        can [:create,:read,:update,:destroy], SdDetail
        can [:create,:read,:update,:destroy, :update_asignatures, :update_field_form, :update_score_detail, :delete_register], ScoreDetail
        can [:create,:read,:update,:destroy, :update_asignatures, :update_field_form, :update_score_detail, :delete_register], EduperScoreDetail
        can [:create,:read,:update], SubGrade
        can [:create,:read,:update], EducationalPerformanceGrade
        can [:create,:read,:update], EducationalPerformancesList
        can [:create,:read,:update], StudentProgress
        can [:create,:read,:update, :update_field_form, :save_data, :update_scores_finals, :student_comment, :save_comment], StudentTracking
        can [:create,:read,:update], StudentSubGrade
    end



    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
