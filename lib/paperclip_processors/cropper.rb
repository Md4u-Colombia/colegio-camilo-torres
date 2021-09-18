module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      if crop_command
        # puts "crop_command: #{crop_command}"
        sup = super
        if sup.class == Array
          sup = sup.join(' ')
        end
        # #puts (crop_command + sup.sub(/ -crop \S+/, '')).sub(/100x/, '100x100')
        # puts "**************************crop_command: #{crop_command}"
        crop_command + ' ' + sup.sub(/ -crop \S+/, '')
        #crop_command + super.sub(/ -crop \S+/, '')
      else
        super
      end
    end

    def crop_command
      target = @attachment.instance
      if target.cropping?
        " -crop '#{target.crop_w.to_i}x#{target.crop_h.to_i}+#{target.crop_x.to_i}+#{target.crop_y.to_i}'"
      end
    end
  end
end
