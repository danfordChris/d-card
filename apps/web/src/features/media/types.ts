// Client-side shapes of the media API (packages/api-contract/src/media.ts, T05-04).

export type MediaKind = "card" | "story" | "gallery";
export type MediaType = "photo" | "video";
export type MediaStatus = "uploading" | "visible" | "hidden" | "reported" | "deleted" | "missing";
export type SharingMode = "private" | "link";

export type MediaLimits = {
  cardPhotos: number;
  cardVideos: number;
  cardVideoSeconds: number;
  storyPhotos: number;
  storyVideos: number;
  storyVideoSeconds: number;
  galleryEnabled: boolean;
  galleryVideoSeconds: number;
  galleryUploadsPerGuest: number;
  galleryUploadDays: number;
  galleryOpenMonths: number;
  maxPhotoBytes: number;
  maxVideoBytes: number;
  slideshow: boolean;
};

export type MediaSettings = {
  mediaEnabled: boolean;
  connected: boolean;
  googleEmail: string | null;
  needsReconnect: boolean;
  sharingMode: SharingMode;
  folderUrl: string | null;
  quotaUsedBytes: number | null;
  quotaLimitBytes: number | null;
  quotaWarning: boolean;
  googlePhotosUrl: string | null;
  limits: MediaLimits;
  counts: { cardPhotos: number; cardVideos: number; storyPhotos: number; storyVideos: number; gallery: number };
};

export type MediaItem = {
  id: string;
  kind: MediaKind;
  type: MediaType;
  mimeType: string;
  sizeBytes: number;
  durationSeconds: number | null;
  status: MediaStatus;
  uploadedBy: string | null;
  mine: boolean;
  thumbnailUrl: string;
  url: string;
  createdAt: string;
};

export type UploadSession = { mediaItemId: string; uploadUrl: string; expiresAt: string };

/** Plan limits for the host editors (card media, story). */
export function editorLimits(limits: MediaLimits, kind: "card" | "story") {
  return kind === "card"
    ? { photos: limits.cardPhotos, videos: limits.cardVideos, videoSeconds: limits.cardVideoSeconds }
    : { photos: limits.storyPhotos, videos: limits.storyVideos, videoSeconds: limits.storyVideoSeconds };
}
