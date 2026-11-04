module Api
  module V1
    class ProjectsController < ApplicationController
      include Authentication

      before_action :set_organization

      def index
        projects = Current.organization.projects.includes(:client)

        render json: {
          projects: projects.map do |project|
            {
              id: project.id,
              name: project.name,
              description: project.description,
              status: project.status,
              start_date: project.start_date,
              end_date: project.end_date,
              client: project.client&.name
            }
          end
        }, status: :ok
      end

      def create
        project = Current.organization.projects.new(project_params)

        if project.save
          render json: {
            id: project.id,
            name: project.name,
            description: project.description,
            status: project.status,
            start_date: project.start_date,
            end_date: project.end_date,
            client_id: project.client_id
          }, status: :created
        else
          render json: {
            errors: project.errors.full_messages
          }, status: :unprocessable_content
        end
      end

      def show
        project = Current.organization.projects.includes(:client).find(params[:id])

        render json: {
          id: project.id,
          name: project.name,
          description: project.description,
          status: project.status,
          start_date: project.start_date,
          end_date: project.end_date,
          client: project.client&.name
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: {
          error: "Project not found"
        }, status: :not_found
      end

      def update
        project = Current.organization.projects.find(params[:id])

        if project.update(project_params)
          render json: {
            id: project.id,
            name: project.name,
            description: project.description,
            status: project.status,
            start_date: project.start_date,
            end_date: project.end_date,
            client_id: project.client_id
          }, status: :ok
        else
          render json: {
            errors: project.errors.full_messages
          }, status: :unprocessable_content
        end
      rescue ActiveRecord::RecordNotFound
        render json: {
          error: "Project not found"
        }, status: :not_found
      end

      def destroy
        project = Current.organization.projects.find(params[:id])

        project.destroy!

        render json: {
          message: "Project deleted successfully"
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: {
          error: "Project not found"
        }, status: :not_found
      end

      private

      def set_organization
        organization_id = request.headers["X-Organization-ID"]

        OrganizationContext.new(
          user: current_user,
          organization_id: organization_id
        ).resolve!
      rescue OrganizationContext::AccessDenied
        render json: {
          error: "Access to this organization is denied"
        }, status: :forbidden
      end

      def project_params
        params.require(:project).permit(
          :client_id,
          :name,
          :description,
          :status,
          :start_date,
          :end_date
        )
      end

    end
  end
end