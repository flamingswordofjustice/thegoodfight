ActiveAdmin.register Episode do
  config.sort_order = "published_at_desc"

  breadcrumb do
    if params[:id].present?
      [
        link_to("Admin", admin_root_path),
        link_to("Episodes", admin_episodes_path),
        link_to(resource.display_name, admin_episode_path(resource))
      ]
    end
  end

  index do
    column "Name", :title
    column :headline
    column :published_at
    column :state
    column(:guests) { |e| e.guests.map {|g| link_to g.name, edit_admin_person_path(g.slug) }.join(', ').html_safe }
    column(:topics) { |e| e.topics.map {|t| link_to t.name, edit_admin_topic_path(t.slug) }.join(', ').html_safe }
    column(:description, sortable: :description) { |e| strip_tags e.description }
    default_actions
  end

  filter :published_at

  show do
    render partial: 'admin/shared/iframe', locals: { src: episode_url(episode) }
  end

  action_item only: [:edit, :show] do
    name = resource.class.model_name
    link_to "View Live #{active_admin_config.resource_label}", send("#{name.singular}_path", resource), target: "_new"
  end

  form html: { multipart: true } do |f|
    f.inputs "Episode Details" do
      f.input :title, label: "Name"
      f.input :download_url
      f.input :description, as: :html_editor
      f.input :show_notes, as: :html_editor
      f.input :state, as: :select, collection: f.object.possible_states, selected: f.object.state || f.object.default_state
      f.input :published_at, as: :date_select
      f.input :image, as: :image_upload, preview: :thumb
      f.input :image_caption
    end

    f.inputs "Social and Sharing" do
      f.input :headline, label: "Catchy headline"
      f.input :social_description, label: "Pithy Facebook description", hint: content_tag(:span, "", class: "charlimit"), input_html: { rows: 3, maxlength: 100 }
      f.input :twitter_text, as: :text, label: "Viral Twitter text", hint: content_tag(:span, "", class: "charlimit") + t("admin.twitter_text").html_safe, input_html: { rows: 3, maxlength: 102 }
    end

    f.inputs "Topics and Guests" do
      f.input :topics, hint: link_to("Add new topic", new_admin_topic_path, target: "_new")
      f.input :guests, hint: link_to("Add new guest", new_admin_person_path, target: "_new")
    end

    f.actions
  end
end
