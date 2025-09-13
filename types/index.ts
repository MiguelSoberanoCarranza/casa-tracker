export interface Prospect {
  id: string;
  name: string;
  email: string;
  phone: string;
  address: string;
  budget: number;
  status: ProspectStatus;
  score: number;
  notes: string;
  createdAt: Date;
  updatedAt: Date;
  interactions: Interaction[];
}

export interface Interaction {
  id: string;
  type: InteractionType;
  response: ResponseType;
  notes: string;
  date: Date;
}

export type InteractionType = 'call' | 'email' | 'meeting' | 'visit' | 'follow_up';
export type ResponseType = 'positive' | 'negative' | 'neutral' | 'no_response';
export type ProspectStatus = 'new' | 'contacted' | 'interested' | 'not_interested' | 'closed';
