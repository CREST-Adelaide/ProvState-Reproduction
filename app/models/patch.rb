class Patch < ApplicationRecord
	mount_uploader :attachment, AttachmentUploader
end
